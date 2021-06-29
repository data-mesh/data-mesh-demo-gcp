package org.data.mesh.data.product.menu;

import avro.shaded.com.google.common.collect.Iterables;
import org.apache.avro.Schema;
import org.apache.avro.generic.GenericData;
import org.apache.avro.generic.GenericRecord;
import org.apache.beam.sdk.coders.AvroCoder;
import org.apache.beam.sdk.coders.KvCoder;
import org.apache.beam.sdk.coders.StringUtf8Coder;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.testing.PAssert;
import org.apache.beam.sdk.testing.TestPipeline;
import org.apache.beam.sdk.testing.ValidatesRunner;
import org.apache.beam.sdk.transforms.*;
import org.apache.beam.sdk.transforms.join.CoGbkResult;
import org.apache.beam.sdk.transforms.join.CoGroupByKey;
import org.apache.beam.sdk.transforms.join.KeyedPCollectionTuple;
import org.apache.beam.sdk.values.KV;
import org.apache.beam.sdk.values.PCollection;
import org.apache.beam.sdk.values.TupleTag;
import org.junit.BeforeClass;
import org.junit.Rule;
import org.junit.Test;
import org.junit.experimental.categories.Category;
import org.junit.runner.RunWith;
import org.junit.runners.JUnit4;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.StreamSupport;

import static org.data.mesh.data.product.menu.NYCRestaurantDataProductProcessor.getSchema;

@RunWith(JUnit4.class)
public class DishProcessorTest implements Serializable {
    @Rule public TestPipeline pipeline = TestPipeline.create();

    public static class WithKeysDish implements SerializableFunction<GenericRecord, String> {

        @Override
        public String apply(GenericRecord input) {
            return input.get("first_name").toString();
        }
    }
    public static class ParseDish extends DoFn<KV<String, CoGbkResult>, KV<String, Integer>> {
        TupleTag<Integer> amountTagDataset1;
        TupleTag<Integer> amountTagDataset2;

        ParseDish(TupleTag<Integer> inputAmountTagDataset1, TupleTag<Integer> inputAmountTagDataset2) {
            amountTagDataset1 = inputAmountTagDataset1;
            amountTagDataset2 = inputAmountTagDataset2;
        }

        @ProcessElement
        public void processElement(ProcessContext processContext) {
            KV<String, CoGbkResult> element = processContext.element();
            Iterable<Integer> dataset1Amounts = element.getValue().getAll(amountTagDataset1);
            Iterable<Integer> dataset2Amounts = element.getValue().getAll(amountTagDataset2);
            Integer sumAmount = StreamSupport.stream(Iterables.concat(dataset1Amounts, dataset2Amounts).spliterator(), false)
                    .collect(Collectors.summingInt(n -> n));
            processContext.output(KV.of(element.getKey(), sumAmount));
        }
    }

    @Test
    @Category(ValidatesRunner.class)
    public void should_join_2_datasets_which_all_have_1_matching_key_with_native_sdk_code() {

        List<KV<String, Integer>> ordersPerUser1 = Arrays.asList(
                KV.of("user1", 1000), KV.of("user2", 200), KV.of("user3", 100)
        );
        List<KV<String, Integer>> ordersPerUser2 = Arrays.asList(
                KV.of("user1", 1100), KV.of("user2", 210), KV.of("user3", 110),
                KV.of("user1", 1200), KV.of("user2", 220), KV.of("user3", 120)
        );

        PCollection<KV<String, Integer>> ordersPerUser1Dataset = pipeline.apply("ordersPerUser1", Create.of(ordersPerUser1));
        PCollection<KV<String, Integer>> ordersPerUser2Dataset = pipeline.apply("ordersPerUser2", Create.of(ordersPerUser2));

        final TupleTag<Integer> amountTagDataset1 = new TupleTag<>();
        final TupleTag<Integer> amountTagDataset2 = new TupleTag<>();
        PCollection<KV<String, CoGbkResult>> groupedCollection = KeyedPCollectionTuple
                .of(amountTagDataset1, ordersPerUser1Dataset)
                .and(amountTagDataset2, ordersPerUser2Dataset)
                .apply(CoGroupByKey.create());

        PCollection<KV<String, Integer>> totalAmountsPerUser = groupedCollection.apply(ParDo.of(new ParseDish(amountTagDataset1, amountTagDataset2)));

        PAssert.that(totalAmountsPerUser).containsInAnyOrder(KV.of("user1", 3300), KV.of("user2", 630),
                KV.of("user3", 330));
        pipeline.run().waitUntilFinish();
    }

    @BeforeClass
    public static void setUp() {
        PipelineOptionsFactory.register(NYCRestaurantDataProductProcessor.MainProcessorOptions.class);
    }

    @Test
    public void testCsvToAvro() throws Exception {
        NYCRestaurantDataProductProcessor.MainProcessorOptions options = TestPipeline.testingPipelineOptions().as(NYCRestaurantDataProductProcessor.MainProcessorOptions.class);

        options.setMenuAvroSchema("examplefiles/input.avsc");
        options.setMenuInputFile("examplefiles/input.csv");
        options.setDishAvroSchema("exampleFiles/dish.avsc");
        options.setDishInputFile("exampleFiles/dish.csv");
        options.setOutputAvroSchema("exampleFiles/output.avsc");

        String menuSchemaJson = getSchema(options.getMenuAvroSchema());
        Schema menuSchema = new Schema.Parser().parse(menuSchemaJson);
        String dishSchemaJson = getSchema(options.getDishAvroSchema());
        Schema dishSchema = new Schema.Parser().parse(dishSchemaJson);
        String outputSchemaJson = getSchema(options.getOutputAvroSchema());
        Schema outputSchema = new Schema.Parser().parse(outputSchemaJson);

        final List<GenericRecord> expectedMenuResult = new ArrayList<>();
        GenericRecord genericRecordOne = new GenericData.Record(menuSchema);
        genericRecordOne.put("first_name", "frank");
        genericRecordOne.put("last_name", "natividad");
        genericRecordOne.put("age", 1);
        expectedMenuResult.add(genericRecordOne);
        GenericRecord genericRecordTwo = new GenericData.Record(menuSchema);
        genericRecordTwo.put("first_name", "Karthi");
        genericRecordTwo.put("last_name", "thyagarajan");
        genericRecordTwo.put("age", 3);
        expectedMenuResult.add(genericRecordTwo);

        final List<GenericRecord> expectedDishResult = new ArrayList<>();
        GenericRecord genericRecordDishOne = new GenericData.Record(dishSchema);
        genericRecordDishOne.put("first_name", "frank");
        genericRecordDishOne.put("last_name", "natividad");
        genericRecordDishOne.put("price", 10000);
        expectedDishResult.add(genericRecordDishOne);
        GenericRecord genericRecordDishTwo = new GenericData.Record(dishSchema);
        genericRecordDishTwo.put("first_name", "Karthi");
        genericRecordDishTwo.put("last_name", "thyagarajan");
        genericRecordDishTwo.put("price", 3000);
        expectedDishResult.add(genericRecordDishTwo);

        final PCollection<GenericRecord> menuRecords = pipeline.apply("Read CSV files menu",
                TextIO.read().from(options.getMenuInputFile()))
                .apply("Convert CSV to Avro formatted data menu", ParDo.of(
                        new MenuProcessor.ConvertCsvLinesToCleanMenuRecords(menuSchemaJson, ",")))
                .setCoder(AvroCoder.of(GenericRecord.class, menuSchema));
        PCollection<KV<String, GenericRecord>> menuNameToRecords =
                menuRecords.apply("menuNameToRecords", WithKeys.of(new WithKeysDish()))
                        .setCoder(KvCoder.of(StringUtf8Coder.of(), AvroCoder.of(GenericRecord.class, menuSchema)));


        PAssert.that(menuRecords).containsInAnyOrder(expectedMenuResult);

        final PCollection<GenericRecord> dishRecords = pipeline.apply("Read CSV files dish",
                TextIO.read().from(options.getDishInputFile()))
                .apply("Convert CSV to Avro formatted data dish", ParDo.of(
                        new DishProcessor.ConvertCsvLinesToCleanDishRecords(dishSchemaJson, ",")))
                .setCoder(AvroCoder.of(GenericRecord.class, dishSchema));

        PAssert.that(dishRecords).containsInAnyOrder(expectedDishResult);

        PCollection<KV<String, GenericRecord>> dishNameToRecords =
                dishRecords.apply("dishNameToRecords", WithKeys.of(new WithKeysDish()))
                .setCoder(KvCoder.of(StringUtf8Coder.of(), AvroCoder.of(GenericRecord.class, dishSchema)));

        PCollection<String> outputKeys = dishNameToRecords.apply(Keys.create());
        PAssert.that(outputKeys).containsInAnyOrder("frank", "Karthi");


        final TupleTag<GenericRecord> dishTag = new TupleTag();
        final TupleTag<GenericRecord> menuTag = new TupleTag();

        PCollection<KV<String, CoGbkResult>> results =
                KeyedPCollectionTuple.of(menuTag, menuNameToRecords)
                        .and(dishTag, dishNameToRecords)
                        .apply(CoGroupByKey.create());
        PCollection<String> stringresults = results.apply(ParDo.of(new OutputFormatter(dishTag, menuTag)));

        PAssert.that(stringresults).containsInAnyOrder("frank,natividad,1,10000", "Karthi,thyagarajan,3,3000");

        pipeline.run().waitUntilFinish();
    }

    public static class OutputFormatter extends DoFn<KV<String, CoGbkResult>, String> {
        public TupleTag<GenericRecord> dishTag;
        public TupleTag<GenericRecord> menuTag;

        OutputFormatter(TupleTag<GenericRecord> dishTag, TupleTag<GenericRecord> menuTag) {
            this.dishTag = dishTag;
            this.menuTag = menuTag;
        }

        @ProcessElement
        public void processElement(ProcessContext c) {
            KV<String, CoGbkResult> e = c.element();
            String name = e.getKey();
            Iterable<GenericRecord> dishIter = e.getValue().getAll(dishTag);
            Iterable<GenericRecord> menuIter = e.getValue().getAll(menuTag);

            String formattedResult =
                    formatCoGbkResults(name, dishIter, menuIter);
            c.output(formattedResult);
        }

    }

    public static String formatCoGbkResults(
            String name, Iterable<GenericRecord> dishes, Iterable<GenericRecord> menu) {

        String result = name;

        for (GenericRecord elem : menu) {
            result = result + "," + elem.get("last_name").toString();
            result = result + "," + elem.get("age").toString();
        }

        for (GenericRecord elem : dishes) {
            result = result + "," + elem.get("price").toString();
        }

        return result;
    }

}
