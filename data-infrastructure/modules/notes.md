

Simple data product type b
 - name
 - inputs
    out of another data product storage/ documents files unstructured data
 - outputs
    sql - (bigquery dataset)
    storage - summary document
 - complex compute - dataflow - not required

 - business logic
        fit for purpose calculation 
        assuming I am ingesting data from storage bucket, doing video analysis
        in bigquery I write my aggregate results

Simple data product type a 
 - name
 - inputs
    out of another data product bigquery
 - outputs
    sql (bigquery dataset)
 - complex compute - dataflow - not required

 - business logic
        fit for purpose calculation 
        assuming I am ingesting data from a bigquery dataset
        in bigquery I can simply run sql scripts and output aggregates/metrics about restaurants and write sql bigquery dataset

Complex data product
 - name
 - inputs
    - blob
 - outputs 
    - sql (bigquery dataset) 
    - blob 
 - complex compute -> dataflow
