data "google_compute_network" "network" {
  name    = var.vpc_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  project = var.project_id
  region  = var.region
  name    = var.subnet
}

# A service connection policy lets you authorize the specified service class to create a Private Service Connect connection between producer and consumer VPC networks.
# https://docs.cloud.google.com/memorystore/docs/valkey/networking#networking_setup_guidance
# resource "google_network_connectivity_service_connection_policy" "service_connection_policy" {
#   project       = var.project_id
#   name          = "memstore-service-connection-policy"
#   location      = data.google_compute_subnetwork.subnetwork.region
#   service_class = "gcp-memorystore"
#   network       = data.google_compute_network.network.id
#   psc_config {
#     subnetworks = [data.google_compute_subnetwork.subnetwork.id]
#   }
# }

resource "google_memorystore_instance" "valkey" {
  # depends_on  = [google_network_connectivity_service_connection_policy.service_connection_policy]
  project     = var.project_id
  location    = data.google_compute_subnetwork.subnetwork.region
  shard_count = 1
  node_type   = "SHARED_CORE_NANO"
  instance_id = var.name
  # https://docs.cloud.google.com/memorystore/docs/valkey/supported-versions
  engine_version = "VALKEY_8_0"

  maintenance_policy {
    weekly_maintenance_window {
      day = "SATURDAY"
      start_time {
        hours   = 1
        minutes = 0
        seconds = 0
        nanos   = 0
      }
    }
  }

  # this block require google_network_connectivity_service_connection_policy
  # to ensure auto create private ip (the endpoint) by the service connection policy
  desired_auto_created_endpoints {
    project_id = var.project_id
    network    = data.google_compute_network.network.id
  }

  deletion_protection_enabled = false
}
