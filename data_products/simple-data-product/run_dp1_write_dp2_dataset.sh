mvn -Pdataflow-runner compile exec:java \
    -Dexec.mainClass=data.mesh.cookbook.DataProductProcessor \
    -Dexec.args="--project=data-mesh-demo \
    --stagingLocation=gs://dp-a-df-temp-y4f4potpgpt8fidu/staging_1/ \
    --gcpTempLocation=gs://dp-a-df-temp-y4f4potpgpt8fidu/temp_1/ \
    --tempLocation=gs://dp-a-df-temp-y4f4potpgpt8fidu/temp_1/ \
    --output=data-mesh-demo:dp2ds.test \
    --runner=DataflowRunner"