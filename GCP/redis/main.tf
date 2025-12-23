data "google_compute_network" "network" {
  name = var.vpc_name
  project = var.project_id
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "redis-private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.network.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_redis_instance" "redis" {
  depends_on = [google_service_networking_connection.private_vpc_connection]
  project = var.project_id
  region = var.region

  name           = var.name
  tier           = "BASIC"
  memory_size_gb = 1

  # location_id             = "asia-east1"

  auth_enabled = true
  authorized_network = data.google_compute_network.network.id
  connect_mode = "PRIVATE_SERVICE_ACCESS"

  redis_version     = "REDIS_7_2"
  display_name      = var.name
  

  maintenance_policy {
    weekly_maintenance_window {
      day = "SATURDAY"
      start_time {
        hours = 0
        minutes = 30
        seconds = 0
        nanos = 0
      }
    }
  }

}
