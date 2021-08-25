# Base infrastructure 

resource "google_project_service" "service" {
  service = "iam.googleapis.com" 

  project = var.project_name
  disable_on_destroy = false
}

# Default VPC network for dataflow firewall rull
resource "google_compute_firewall" "default" {
  name    = "dataflow-traffic"
  network = google_compute_network.default.name

  allow {
    protocol = "tcp"
    ports    = ["12345-12346"]
  }

  target_tags = ["dataflow"]
}

# Allow ingress of dataflow
resource "google_compute_network" "default" {
  name = "default"
}

# -------Data Product A ---------------
# DPA Service Account
resource "google_service_account" "service_account-dp-a" {
  account_id   = "dp-a-sa"
  display_name = "Service Account for data product A"
}

# DPA Compute

data "google_iam_policy" "dp-a-temp-sb-policy" {
  binding {
    role = "roles/storage.objectAdmin"
    members = [
      "serviceAccount:${var.project_id}-compute@developer.gserviceaccount.com",
      # So that we can destroy the temp storage account if needed via terraform destroy
      "serviceAccount:data-mesh-base-infra-provision@${var.project_name}.iam.gserviceaccount.com",
    ]
  }

  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.service_account-dp-a.email}",
    ]
  }

  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:data-mesh-base-infra-provision@${var.project_name}.iam.gserviceaccount.com",
      "serviceAccount:${google_service_account.service_account-dp-a.email}",
    ]
  }
}

resource "google_storage_bucket_iam_policy" "dp-a-dataflow-temp-sb-policy" {
  bucket = google_storage_bucket.dp-a-dataflow-temp.name
  policy_data = data.google_iam_policy.dp-a-temp-sb-policy.policy_data
}

resource "google_project_iam_member" "dp-a-sa-bq-job-user" {
  project = var.project_name
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.service_account-dp-a.email}"
}

resource "google_project_iam_member" "dp-a-sa-dataflow-developer" {
  project = var.project_name
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${google_service_account.service_account-dp-a.email}"
}

resource "google_project_iam_member" "dp-a-sa-compute-viewer" {
  project = var.project_name
  role    = "roles/compute.viewer"
  member  = "serviceAccount:${google_service_account.service_account-dp-a.email}"
}

resource "google_storage_bucket" "dp-a-dataflow-temp" {
  name          = "dp-a-df-temp-${random_string.random_dp_id.id}"
  location      = "US"
  force_destroy = true
}

# DPA Admin Input/Output Storage policy

data "google_iam_policy" "dp-a-admin" {
  binding {
    role = "roles/storage.objectCreator"
    members = [
      "serviceAccount:${google_service_account.service_account-dp-a.email}",
    ]
  }

  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:data-mesh-base-infra-provision@${var.project_name}.iam.gserviceaccount.com",
      "serviceAccount:${google_service_account.service_account-dp-a.email}",
    ]
  }
}

# DPA Inputs
## DPA Input Storage Bucket
resource "google_storage_bucket" "dp-a-sb" {
  name          = "dp-a-input-${random_string.random_dp_id.id}"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_iam_policy" "dp-a-sb-policy" {
  bucket = google_storage_bucket.dp-a-sb.name
  policy_data = data.google_iam_policy.dp-a-admin.policy_data
}

# DPA Outputs

## DPA Output Bigquery Dataset
resource "google_bigquery_dataset" "dataset-dp-a" {
  dataset_id                  = "dp1ds"
  friendly_name               = "dp1-dataset"
  location                    = "US"
  default_table_expiration_ms = 3600000
  default_partition_expiration_ms = 5184000000
  delete_contents_on_destroy = true

  access {
    role          = "OWNER"
    user_by_email = google_service_account.service_account-dp-a.email
  }

  # TODO Refactor this such that dataset-dp-a has a role binding to access group dp-a-consumers, such that data product b
  access {
    role = "READER"
    user_by_email = google_service_account.service_account-dp-b.email
  }
}

resource "random_string" "random_dp_id" {
  length           = 16
  special          = false
  upper = false
}

## DPA Output Storage Bucket

resource "google_storage_bucket" "dp-a-output-sb" {
  name          = "dp-a-output-${random_string.random_dp_id.id}"
  location      = "US"
  force_destroy = true
}

resource "google_storage_bucket_iam_policy" "dp-a-output-sb-policy" {
  bucket = google_storage_bucket.dp-a-output-sb.name
  policy_data = data.google_iam_policy.dp-a-admin.policy_data
}

# -------Data Product B---------------

# DPB Service account
resource "google_service_account" "service_account-dp-b" {
  account_id   = "dp-b-sa"
  display_name = "Service Account for data product B"
}

# DPB Compute
resource "google_project_iam_member" "dp-b-sa-bq-job-user" {
  role    = "roles/bigquery.jobUser"
  member  = "serviceAccount:${google_service_account.service_account-dp-b.email}"
}

# DPB Outputs

## DPB Output Bigquery dataet
resource "google_bigquery_dataset" "dataset-dp-b" {
  dataset_id                  = "dp2ds"
  friendly_name               = "dp2-dataset"
  location                    = "US"
  default_table_expiration_ms = 3600000
  default_partition_expiration_ms = 5184000000

  access {
    role          = "OWNER"
    user_by_email = google_service_account.service_account-dp-b.email
  }
}