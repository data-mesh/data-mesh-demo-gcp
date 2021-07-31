# DP1 Service Account
resource "google_service_account" "data_product_service_account" {
  account_id   = var.data_product_account_name
  display_name = "Service Account for ${var.data_product_account_name}"
}

# DP1 Output port
module "dataset1" {
  source = "../port-bigquery-dataset"
  dataset_name = "output_1"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
  consumer_email = var.consumer_email
}

resource "random_string" "random_dp_id" {
  length           = 16
  special          = false
  upper = false
}


# output storage bucket
module "data_product_output_1_storage" {
  source = "../port-storage-bucket"
  port_name = "output.1"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
}

# DP1 Input port

#input storage bucket
module "data_product_input_1_storage" {
  source = "../port-storage-bucket"
  port_name = "input.1"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
}

# Temp storage bucket for data flow processor
module "data_product_dataflow_temp_storage" {
  source = "../dataflow-storage-bucket"
  data_product_name = var.data_product_name
  data_product_owner_email = google_service_account.data_product_service_account.email
  project_name = var.project_name
  project_id = var.project_id
}

resource "google_project_iam_member" "dp-a-sa-bq-job-user" {
  project = var.project_name
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

resource "google_project_iam_member" "dp-a-sa-dataflow-developer" {
  project = var.project_name
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

resource "google_project_iam_member" "dp-a-sa-compute-viewer" {
  project = var.project_name
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}


# TODO Output each storage and dataset paths