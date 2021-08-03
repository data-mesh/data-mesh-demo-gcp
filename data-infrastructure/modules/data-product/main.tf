# Data Product Service Account
resource "google_service_account" "data_product_service_account" {
  account_id   = var.data_product_name
  display_name = "Service Account for ${var.data_product_name}"
}

# For compute in dataflow

module "data_product_dataflow_temp_storage" {
  count= var.compute ? 1 : 0
  source = "../dataflow-storage-bucket"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
  project_id = var.project_id
}

resource "google_project_iam_member" "dataflow_developer" {
  count= var.compute ? 1 : 0
  project = var.project_name
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

resource "google_project_iam_member" "compute" {
  count= var.compute ? 1 : 0
  project = var.project_name
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

# For creating jobs that can query big query tables
resource "google_project_iam_member" "bigquery_user" {
  count= var.compute ? 1 : 0
  project = var.project_name
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

# SQL Inputs

module "sql_inputs" {
  source   = "../port-bigquery-dataset"
  for_each =  {for key, val in var.inputs: 
               key => val if val.input_type == "SQL"}
  dataset_name     = "input_${each.value.name}"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
}


# Storage Inputs
module "storage_inputs" {
  source = "../port-storage-bucket"
  for_each =  {for key, val in var.inputs: 
               key => val if val.input_type == "Storage"}
  
  port_name = "input-${each.value.name}"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
}


# SQL Outputs

module "sql_outputs" {
  source   = "../port-bigquery-dataset"
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
  source = "../port-storage-bucket"
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
  value = module.data_product_dataflow_temp_storage.*.url
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