mvn compile -Pdataflow-runner compile exec:java \
    -Dexec.mainClass=org.data.mesh.data.product.menu.NYCRestaurantDataProductProcessor \
    -Dexec.args="--project=data-mesh-demo \
    --stagingLocation=gs://dp-a-df-temp/staging/ \
    --gcpTempLocation=gs://dp-a-df-temp/temp_loc/ \
    --tempLocation=gs://dp-a-df-temp/temp/ \
    --region=us-central1\
   --menuInputFile=gs://dp-a-input/examplefiles/samples/menu.csv \
   --menuPageInputFile=gs://dp-a-input/examplefiles/samples/menupage.csv \
   --menuItemInputFile=gs://dp-a-input/examplefiles/samples/menuitem.csv \
   --dishInputFile=gs://dp-a-input/examplefiles/samples/dish.csv \
   --menuAvroSchema=gs://dp-a-input/examplefiles/schemas/Menu.avsc \
   --menuPageAvroSchema=gs://dp-a-input/examplefiles/schemas/MenuPage.avsc \
   --menuItemAvroSchema=gs://dp-a-input/examplefiles/schemas/MenuItem.avsc \
   --dishAvroSchema=gs://dp-a-input/examplefiles/schemas/Dish.avsc \
   --outputAvroSchema=gs://dp-a-input/examplefiles/output.avsc \
   --outputDir=gs://dp-a-output \
   --csvDelimiter=',' \
    --runner=DataflowRunner"