# DP1 Service Account
resource "google_service_account" "data_product_service_account" {
  account_id   = var.data_product_account_name
  display_name = "Service Account for ${var.data_product_account_name}"
}

# DP1 Output port

# SQL Inputs

module "sql_inputs" {
  source   = "../port-bigquery-dataset"
  for_each =  {for key, val in var.inputs: 
               key => val if val.type == "SQL"}
  dataset_name     = each.name
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
}


# Storage Inputs
module "storage_inputs" {
  source = "../port-storage-bucket"
  for_each =  {for key, val in var.inputs: 
               key => val if val.type == "Storage"}
  
  port_name = "output.${each.name}"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
}


# SQL Outputs

module "sql_outputs" {
  source   = "../port-bigquery-dataset"
  for_each =  {for key, val in var.outputs: 
               key => val if val.type == "SQL"}
  dataset_name     = each.name
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
}


# Storage Outputs
module "storage_outputs" {
  source = "../port-storage-bucket"
  for_each =  {for key, val in var.outputs: 
               key => val if val.type == "Storage"}
  
  port_name = "output.${each.name}"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
}


# resource "google_project_iam_member" "dp-a-sa-bq-job-user" {
#   project = var.project_name
#   role    = "roles/bigquery.jobUser"
#   member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
# }

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


# TODO Output each storage and dataset paths