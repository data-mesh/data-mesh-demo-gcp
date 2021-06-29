package org.data.mesh.data.product.menu;

import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.beam.sdk.transforms.DoFn;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

//import org.apache.beam.sdk.io.parquet.ParquetIO;

public class MenuProcessor {

    static class ConvertCsvLinesToCleanMenuRecords extends DoFn<String, GenericRecord> {

        private static final Logger LOG = LoggerFactory.getLogger(MenuProcessor.class);

        private String delimiter;
        private String schemaJson;

        public ConvertCsvLinesToCleanMenuRecords(String schemaJson, String delimiter) {
            this.schemaJson = schemaJson;
            this.delimiter = delimiter;
        }

        @ProcessElement
        public void processElement(@Element String element, DoFn.OutputReceiver<GenericRecord> receiver) throws Exception{
            String[] rowValues = element.split(delimiter);

            Schema schema = new Schema.Parser().parse(schemaJson);

            GenericRecord genericRecord = new GenericData.Record(schema);
            List<Schema.Field> fields = schema.getFields();

//            if(rowValues.length > 0 && rowValues[0].startsWith("id")) {
//                return;
//            }

            for (int index = 0; index < fields.size(); index++) {
                Schema.Field field = fields.get(index);
                String fieldType = field.schema().getType().getName().toLowerCase();

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
                        genericRecord.put(field.name(), Long.valueOf(rowValues[index]));
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
            }

            receiver.output(genericRecord);
        }
    }

}