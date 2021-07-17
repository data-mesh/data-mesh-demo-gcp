mvn -Pdataflow-runner compile exec:java \
    -Dexec.mainClass=data.mesh.cookbook.DataProductProcessor \
    -Dexec.args="--project=data-mesh-demo \
    --stagingLocation=gs://dp-a-df-temp-y4f4potpgpt8fidu/staging/ \
    --gcpTempLocation=gs://dp-a-df-temp-y4f4potpgpt8fidu/temp_loc/ \
    --tempLocation=gs://dp-a-df-temp-y4f4potpgpt8fidu/temp/ \
    --output=data-mesh-demo:dp1ds.test \
    --runner=DataflowRunner"