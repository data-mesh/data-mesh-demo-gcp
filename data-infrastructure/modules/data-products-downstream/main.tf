# DP2 Service account
resource "google_service_account" "data_product_service_account" {
  account_id   = var.service_account_name
  display_name = "Service Account for data product"
}

resource "google_project_iam_member" "data_product_service_account_big_query_job_user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

# DP2 output port
resource "google_bigquery_dataset" "dataset_data_product" {
  dataset_id                  = var.service_account_name
  friendly_name               = "${var.service_account_name}_dataset"
  location                    = "US"
  default_table_expiration_ms = 3600000
  default_partition_expiration_ms = 5184000000

  access {
    role          = "OWNER"
    user_by_email = google_service_account.data_product_service_account.email
  }
}