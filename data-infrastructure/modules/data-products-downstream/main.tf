# DP2 Service account
resource "google_service_account" "data_product_service_account" {
  account_id   = var.data_product_account_name
  display_name = "Service Account for data product"
}

resource "google_project_iam_member" "data_product_service_account_big_query_job_user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.data_product_service_account.email}"
}

module "dataset1_output" {
  source = "output-bigquery-dataset"
  dataset_name = "output_1"
  data_product_name = var.data_product_name
  owner_email = google_service_account.data_product_service_account.email
  consumer_email = var.consumer_email
}
