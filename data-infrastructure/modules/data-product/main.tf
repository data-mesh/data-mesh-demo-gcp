# Data Product Service Account
resource "google_service_account" "data_product_service_account" {
  account_id   = var.data_product_name
  display_name = "Service Account for ${var.data_product_name}"
}

# For compute in dataflow

module "compute" {
  count= var.compute ? 1 : 0
  source = "../compute"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
  project_id = var.project_id
}


# SQL Inputs

module "sql_inputs" {
  source   = "../bigquery-dataset"
  for_each =  {for key, val in var.inputs: 
               key => val if val.input_type == "SQL"}
  dataset_name     = "input_${each.value.name}"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
}


# Storage Inputs
module "storage_inputs" {
  source = "../storage-bucket"
  for_each =  {for key, val in var.inputs: 
               key => val if val.input_type == "Storage"}
  
  port_name = "input-${each.value.name}"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
}


# SQL Outputs

module "sql_outputs" {
  source   = "../bigquery-dataset"
  for_each =  {for key, val in var.outputs: 
               key => val if val.output_type == "SQL"}
  dataset_name     = "output_${each.value.name}"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
  consumers = [{
    "email"=each.value.consumer_email
  }]
}

# Storage Outputs
module "storage_outputs" {
  source = "../storage-bucket"
  for_each =  {for key, val in var.outputs: 
               key => val if val.output_type == "Storage"}
  
  port_name = "output-${each.value.name}"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
  consumers = [{
    "email"=each.value.consumer_email
  }]
  project_name = var.project_name
}


# TODO Output each storage and dataset paths

output "data_flow_bucket" {
  value = module.compute.*.url
}

output "inputs_addresses" {
  value = setunion(
    toset([ for input in module.storage_inputs : ({"id": input.id, "path": input.url, "self_link": input.self_link}) ]),
    toset([ for input in module.sql_inputs : ({"id": input.id, "path": input.id, "self_link": input.self_link}) ])
  )
}

output "outputs_addresses" {
  value = setunion(
    toset([ for output in module.storage_outputs : ({"id": output.id, "path": output.url, "self_link": output.self_link}) ]),
    toset([ for output in module.sql_outputs : ({"id": output.id, "path": output.id, "self_link": output.self_link}) ])
  )
}