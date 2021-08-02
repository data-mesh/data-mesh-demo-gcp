## base infra
resource "google_project_service" "service" {
  service = "iam.googleapis.com" 

  project = var.project_name
  disable_on_destroy = false
}


## base infra
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

## base infra
# Allow ingress of dataflow
resource "google_compute_network" "default" {
  name = "default"
}