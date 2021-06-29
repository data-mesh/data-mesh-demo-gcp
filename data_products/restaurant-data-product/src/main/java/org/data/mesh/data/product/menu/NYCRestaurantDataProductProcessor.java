package org.data.mesh.data.product.menu;

import com.google.protobuf.Int32Value;
import io.opencensus.stats.Aggregation;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericRecord;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.coders.*;
import org.apache.beam.sdk.io.AvroIO;
import org.apache.beam.sdk.io.FileIO;
import org.apache.beam.sdk.io.FileSystems;
import org.apache.beam.sdk.io.TextIO;
//import org.apache.beam.sdk.io.parquet.ParquetIO;
import org.apache.beam.sdk.options.*;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.transforms.join.CoGbkResult;
import org.apache.beam.sdk.transforms.join.CoGroupByKey;
import org.apache.beam.sdk.transforms.join.KeyedPCollectionTuple;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.TupleTag;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import sun.rmi.runtime.Log;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.util.Arrays;
import java.util.List;

public class NYCRestaurantDataProductProcessor {

    private static final Logger LOG = LoggerFactory.getLogger(NYCRestaurantDataProductProcessor.class);

    private static final List<String> acceptedTypes = Arrays.asList(
            new String[]{"string", "boolean", "int", "long", "float", "double"});

    public static String getSchema(String schemaPath) throws IOException {
        ReadableByteChannel chan = FileSystems.open(FileSystems.matchNewResource(
                schemaPath, false));

        try (InputStream stream = Channels.newInputStream(chan)) {
            BufferedReader streamReader = new BufferedReader(new InputStreamReader(stream, "UTF-8"));
            StringBuilder dataBuilder = new StringBuilder();

            String line;
            while ((line = streamReader.readLine()) != null) {
                dataBuilder.append(line);
            }

            return dataBuilder.toString();
        }
    }

    public static void checkFieldTypes(Schema schema) throws IllegalArgumentException {
        for (Schema.Field field : schema.getFields()) {
            String fieldType = field.schema().getType().getName().toLowerCase();
            if (!acceptedTypes.contains(fieldType)) {
                throw new IllegalArgumentException("Field type " + fieldType + " is not supported.");
            }
        }
    }

    public interface MainProcessorOptions extends PipelineOptions {
        @Description("Menu input file path")
        @Validation.Required
        String getMenuInputFile();
        void setMenuInputFile(String value);

        @Description("Menu page input file path")
        @Validation.Required
        String getMenuPageInputFile();
        void setMenuPageInputFile(String value);

        @Description("Menu item input file path")
        @Validation.Required
        String getMenuItemInputFile();
        void setMenuItemInputFile(String value);

        @Description("Dish input file path")
        String getDishInputFile();
        void setDishInputFile(String value);

        @Description("Output directory")
        @Validation.Required
        String getOutputDir();
        void setOutputDir(String value);

        @Description(
                "Set menu avroSchema required parameter to specify location of the schema. A local path and "
                        + "Google Cloud Storage path are supported.")
        @Validation.Required
        String getMenuAvroSchema();
        void setMenuAvroSchema(String value);

        @Description("Set menu page avro schema required parameter to specify location of the schema. A local path and "
                + "Google Cloud Storage path are supported.")
        @Validation.Required
        String getMenuPageAvroSchema();
        void setMenuPageAvroSchema(String value);

        @Description("Set menu item avro schema required parameter to specify location of the schema. A local path and "
                + "Google Cloud Storage path are supported.")
        @Validation.Required
        String getMenuItemAvroSchema();
        void setMenuItemAvroSchema(String value);

        @Description(
                "Set dish avroSchema required parameter to specify location of the schema. A local path and "
                        + "Google Cloud Storage path are supported.")
        @Validation.Required
        String getDishAvroSchema();
        void setDishAvroSchema(String value);

        @Description(
                "Set output avroSchema required parameter to specify location of the schema. A local path and "
                        + "Google Cloud Storage path are supported.")
        @Validation.Required
        String getOutputAvroSchema();
        void setOutputAvroSchema(String value);

        @Description(
                "Set csvDelimiter optional parameter to specify the CSV delimiter. Default delimiter is set"
                        + " to a comma.")
        @Default.String(",")
        String getCsvDelimiter();
        void setCsvDelimiter(String delimiter);
    }

    static void runMainProcessor(MainProcessorOptions options) throws IOException {
        FileSystems.setDefaultPipelineOptions(options);
        Pipeline p = Pipeline.create(options);

        // Get Avro Schema
        String menuSchemaJson = getSchema(options.getMenuAvroSchema());
        Schema menuSchema = new Schema.Parser().parse(menuSchemaJson);
        String dishSchemaJson = getSchema(options.getDishAvroSchema());
        Schema dishSchema = new Schema.Parser().parse(dishSchemaJson);
        String menuItemSchemaJson = getSchema(options.getMenuItemAvroSchema());
        Schema menuItemSchema = new Schema.Parser().parse(menuItemSchemaJson);
        String menuPageSchemaJson = getSchema(options.getMenuPageAvroSchema());
        Schema menuPageSchema = new Schema.Parser().parse(menuPageSchemaJson);

        // Check schema field types before starting the Dataflow job
        checkFieldTypes(menuSchema);
        checkFieldTypes(dishSchema);

        PCollection<GenericRecord> menuRecords = p.apply("Read Menu Data", TextIO.read().from(options.getMenuInputFile()))
                .apply("parse menu data", ParDo.of(new MenuProcessor.ConvertCsvLinesToCleanMenuRecords(menuSchemaJson, options.getCsvDelimiter())))
                .setCoder(AvroCoder.of(GenericRecord.class, menuSchema));

        PCollection<GenericRecord> menuPageRecords = p.apply("Read Menu Page Data", TextIO.read().from(options.getMenuPageInputFile()))
                .apply("parse menu page data", ParDo.of(new MenuPageProcessor.ConvertCsvLinesToCleanMenuPageRecords(menuPageSchemaJson, options.getCsvDelimiter())))
                .setCoder(AvroCoder.of(GenericRecord.class, menuPageSchema));

        PCollection<GenericRecord> menuItemRecords = p.apply("Read Menu Item Data", TextIO.read().from(options.getMenuItemInputFile()))
                .apply("parse menu item data", ParDo.of(new MenuItemProcessor.ConvertCsvLinesToCleanMenuItemRecords(menuItemSchemaJson, options.getCsvDelimiter())))
                .setCoder(AvroCoder.of(GenericRecord.class, menuItemSchema));

        PCollection<GenericRecord> dishRecords = p.apply("Read Dish Data", TextIO.read().from(options.getDishInputFile()))
                .apply("parse dish data", ParDo.of(new DishProcessor.ConvertCsvLinesToCleanDishRecords(dishSchemaJson, options.getCsvDelimiter())))
                .setCoder(AvroCoder.of(GenericRecord.class, dishSchema));

        menuRecords
                .apply("write menu to blob output", FileIO.<GenericRecord>write().via(AvroIO.sink(menuSchema)).to(options.getOutputDir()).withPrefix("menu").withSuffix(".avro"));

        menuPageRecords
                .apply("write menu page to blob output", FileIO.<GenericRecord>write().via(AvroIO.sink(menuPageSchema)).to(options.getOutputDir()).withPrefix("menupage").withSuffix(".avro"));

        menuItemRecords
                .apply("write menu item to blob output", FileIO.<GenericRecord>write().via(AvroIO.sink(menuItemSchema)).to(options.getOutputDir()).withPrefix("menuitem").withSuffix(".avro"));

        dishRecords
                .apply("write dish to blob output", FileIO.<GenericRecord>write().via(AvroIO.sink(dishSchema)).to(options.getOutputDir()).withPrefix("dish").withSuffix(".avro"));


        PCollection<KV<String, GenericRecord>> menuItemDishIdToRecords =
                menuItemRecords.apply("menuItemDishIdToRecords", WithKeys.of(new WithDishKeys("dish_id")))
                        .setCoder(KvCoder.of(StringUtf8Coder.of(), AvroCoder.of(GenericRecord.class, menuItemSchema)));


        PCollection<KV<String, GenericRecord>> dishIdToRecords =
                dishRecords.apply("dishIdToRecords", WithKeys.of(new WithDishKeys("id")))
                        .setCoder(KvCoder.of(StringUtf8Coder.of(), AvroCoder.of(GenericRecord.class, dishSchema)));

        // Denormalize the records for analytical ports in big query
        final TupleTag<GenericRecord> menuTag = new TupleTag();
        final TupleTag<GenericRecord> menuItemTag = new TupleTag();
        final TupleTag<GenericRecord> menuPageTag = new TupleTag();
        final TupleTag<GenericRecord> dishTag = new TupleTag();



        PCollection<KV<String, CoGbkResult>> results =
                KeyedPCollectionTuple.of(menuItemTag, menuItemDishIdToRecords)
                        .and(dishTag, dishIdToRecords)
                        .apply(CoGroupByKey.create());


        PCollection<String> stringresults = results.apply(ParDo.of(new OutputFormatter(dishTag, menuItemTag)));
        stringresults.apply("Write results", TextIO.write().to(options.getOutputDir()).withSuffix(".txt"));

        // TODO: write to big query table

        p.run().waitUntilFinish();
    }

    public static void main(String[] args) throws IOException {
        MainProcessorOptions options =
                PipelineOptionsFactory.fromArgs(args).withValidation().as(MainProcessorOptions.class);

        runMainProcessor(options);
    }

    public static class WithDishKeys implements SerializableFunction<GenericRecord, String> {
        private String keyname;
        private static final Logger LOG = LoggerFactory.getLogger(WithDishKeys.class);

        public WithDishKeys(String keyname) {
            this.keyname = keyname;
        }

        @Override
        public String apply(GenericRecord input) {
            return input.get(keyname).toString();
        }
    }

    public static class OutputFormatter extends DoFn<KV<String, CoGbkResult>, String> {
        public TupleTag<GenericRecord> dishTag;
        public TupleTag<GenericRecord> menuItemTag;

        OutputFormatter(TupleTag<GenericRecord> dishTag, TupleTag<GenericRecord> menuItemTag) {
            this.dishTag = dishTag;
            this.menuItemTag = menuItemTag;
        }

        @ProcessElement
        public void processElement(ProcessContext c) {
            KV<String, CoGbkResult> e = c.element();

            String name = e.getKey();
            Iterable<GenericRecord> dishIter = e.getValue().getAll(dishTag);
            Iterable<GenericRecord> menuIter = e.getValue().getAll(menuItemTag);

            String formattedResult =
                    formatCoGbkResults(name, dishIter, menuIter);
            c.output(formattedResult);
        }

    }

    public static String formatCoGbkResults(
            String name, Iterable<GenericRecord> dishes, Iterable<GenericRecord> menu) {

        String result = name;

        // 1 menu item maps to 1 dish id
        // 2 menu item maps to same dish id
        // for a given dish id print all menu items

        for (GenericRecord elem : menu) {
            LOG.info("testing red"  +  elem.get("id").toString());
            result = result + "," + elem.get("id").toString();
            result = result + "," + elem.get("menu_page_id").toString();
            result = result + "," + elem.get("dish_id").toString();
            for (GenericRecord dishelem : dishes) {
                result = result + "," + dishelem.get("name").toString();
                result = result + "," + dishelem.get("description").toString();
            }
        }



        return result;
    }

    private static class MyMap extends SimpleFunction < Long, Long > {
        public Long apply(Long in ) {
            LOG.info("Length is: " + in );
            return in;
        }
    }

}