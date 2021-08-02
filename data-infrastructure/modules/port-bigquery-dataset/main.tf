resource "google_bigquery_dataset" "dataset" {
  # Can only have _ so we namespace by underscores
  dataset_id                  = "${var.data_product_name}_${var.dataset_name}"
  location                    = var.location
  default_table_expiration_ms = 3600000
  default_partition_expiration_ms = 5184000000
  delete_contents_on_destroy = true

  access {
    role          = "OWNER"
    user_by_email = var.owner_email
  }

  dynamic "access" {
    for_each = {for key, val in var.consumers: 
               key => val if val.email != ""}
      content {
        role = "READER"
        group_by_email = access.value["email"]
      }
  }
}