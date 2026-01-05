data "google_compute_network" "network" {
  name    = var.vpc_name
  project = var.project_id
}

resource "google_compute_subnetwork" "subnetwork" {
  project = var.project_id
  network = data.google_compute_network.network.id
  region  = var.region

  name          = var.subnet.name
  ip_cidr_range = var.subnet.cidr_range
  dynamic "secondary_ip_range" {
    for_each = var.subnet.secondary_ip_range

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

resource "google_network_connectivity_service_connection_policy" "service_connection_policy" {
  name          = "memstore_service_connection_policy"
  location      = var.region
  service_class = "gcp-memorystore"
  network       = data.google_compute_network.network.id
  psc_config {
    subnetworks = [google_compute_subnetwork.subnetwork.id]
  }
}

resource "google_memorystore_instance" "valkey" {
  project     = var.project_id
  location    = var.region
  shard_count = 1
  instance_id = var.name

  maintenance_policy {
    weekly_maintenance_window {
      day = "SATURDAY"
      start_time {
        hours   = 0
        minutes = 30
        seconds = 0
        nanos   = 0
      }
    }
  }

  desired_auto_created_endpoints {
    project_id = var.project_id
    network    = data.google_compute_network.network.id
  }

}
