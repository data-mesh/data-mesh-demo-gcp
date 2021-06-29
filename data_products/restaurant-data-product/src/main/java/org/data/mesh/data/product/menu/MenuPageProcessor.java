package org.data.mesh.data.product.menu;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.beam.sdk.transforms.DoFn;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.logging.Logger;

public class MenuPageProcessor {
    public static class ConvertCsvLinesToCleanMenuPageRecords extends DoFn<String, GenericRecord> {

        private static final org.slf4j.Logger LOG = LoggerFactory.getLogger(MenuPageProcessor.class);
        private String delimiter;
        private String schemaJson;

        public ConvertCsvLinesToCleanMenuPageRecords(String schemaJson, String delimiter) {
            this.schemaJson = schemaJson;
            this.delimiter = delimiter;
        }

        @ProcessElement
        public void processElement(@Element String element, DoFn.OutputReceiver<GenericRecord> receiver) {
            Logger log = Logger.getLogger(DishProcessor.ConvertCsvLinesToCleanDishRecords.class.getName());
            String[] rowValues = element.split(delimiter);

            Schema schema = new Schema.Parser().parse(schemaJson);

            GenericRecord genericRecord = new GenericData.Record(schema);
            List<Schema.Field> fields = schema.getFields();
            if(rowValues.length < fields.size()){
                return;
            }

//            if(rowValues.length > 0 && rowValues[0].startsWith("id")) {
//                return;
//            }

            for (int index = 0; index < fields.size(); ++index) {
                Schema.Field field = fields.get(index);
                if(field.name().startsWith("dish_id"))
                {
                    LOG.info("dish id" +  rowValues[index]);
                    if(rowValues[index].isEmpty())
                        return;
                }

                String fieldType = field.schema().getType().getName().toLowerCase();

                try {
                    // skip putting data into generic record since column is not need
                    switch (fieldType) {
                        case "string":
                            genericRecord.put(field.name(), rowValues[index]);
                            break;
                        case "boolean":
                            genericRecord.put(field.name(), Boolean.valueOf(rowValues[index]));
                            break;
                        case "int":
                            genericRecord.put(field.name(), Integer.valueOf(rowValues[index]));
                            break;
                        case "long":
                            try {
                                genericRecord.put(field.name(), Long.valueOf(rowValues[index]));
                            } catch (Exception ex) {
                                log.info(rowValues[index]);
                            }
                            break;
                        case "float":
                            genericRecord.put(field.name(), Float.valueOf(rowValues[index]));
                            break;
                        case "double":
                            genericRecord.put(field.name(), Double.valueOf(rowValues[index]));
                            break;
                        default:
                            throw new IllegalArgumentException("Field type " + fieldType + " is not supported.");
                    }
                }catch (Exception ex) {
                    log.info(rowValues[index]);
                    continue;
                }
            }
            receiver.output(genericRecord);
        }
    }

}
