mvn clean compile exec:java -Dexec.mainClass=org.data.mesh.data.product.menu.NYCRestaurantDataProductProcessor \
        -Dexec.args="\
         --menuInputFile=examplefiles/samples/menu.csv \
         --menuPageInputFile=examplefiles/samples/menupage.csv \
         --menuItemInputFile=examplefiles/samples/menuitem.csv \
         --dishInputFile=examplefiles/samples/dish.csv \
         --menuAvroSchema=examplefiles/schemas/menu.avsc \
         --menuPageAvroSchema=examplefiles/schemas/menupage.avsc \
         --menuItemAvroSchema=examplefiles/schemas/menuitem.avsc \
         --dishAvroSchema=examplefiles/schemas/dish.avsc \
         --outputAvroSchema=examplefiles/output.avsc \
         --outputDir=nyc_data_product_output \
         --csvDelimiter=','" \
         -Pdirect-runner

