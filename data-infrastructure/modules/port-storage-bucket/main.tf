resource "random_string" "random_dp_id" {
  length           = 16
  special          = false
  upper = false
}

resource "google_storage_bucket" "storage_bucket" {
  name          = "${var.data_product_name}.${var.port_name}.${random_string.random_dp_id.id}"
  location      = var.location
  force_destroy = true
}

resource "google_storage_bucket_iam_policy" "storage_bucket_iam_policy" {
  bucket = google_storage_bucket.storage_bucket.name
  policy_data = data.google_iam_policy.storage_bucket_owner.policy_data
}

data "google_iam_policy" "storage_bucket_owner" {
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