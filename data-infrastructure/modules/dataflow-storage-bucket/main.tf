resource "random_string" "random_dp_id" {
  length           = 16
  special          = false
  upper = false
}

resource "google_storage_bucket" "dataflow_temp" {
  name          = "${var.data_product_name}-dataflow-temp-${random_string.random_dp_id.id}"
  location      = var.location
  force_destroy = true
}

resource "google_storage_bucket_iam_policy" "dataflow_temp" {
  bucket = google_storage_bucket.dataflow_temp.name
  policy_data = data.google_iam_policy.dataflow_temp.policy_data
}

data "google_iam_policy" "dataflow_temp" {
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
      "serviceAccount:${var.data_product_owner_email}",
    ]
  }

  binding {
    role = "roles/storage.admin"
    members = [
      "serviceAccount:data-mesh-base-infra-provision@${var.project_name}.iam.gserviceaccount.com",
      "serviceAccount:${var.data_product_owner_email}",
    ]
  }
}

output "random_id" {
  value = random_string.random_dp_id.id
}

output url {
  value = google_storage_bucket.dataflow_temp.url
}

output self_link {
  value = google_storage_bucket.dataflow_temp.self_link
}