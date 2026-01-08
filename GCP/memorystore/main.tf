data "google_compute_network" "network" {
  project = var.project_id
  name    = var.vpc_name
}

data "google_compute_subnetwork" "subnetwork" {
  project = var.project_id
  name    = var.subnet.name
  region  = var.subnet.region
}

# Ensure service connection policy is existed in target network before create memorystore instance
resource "google_memorystore_instance" "valkey" {
  project     = var.project_id
  location    = data.google_compute_subnetwork.subnetwork.region
  shard_count = 1
  node_type   = "SHARED_CORE_NANO"
  instance_id = var.instance_name
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

  persistence_config {
    mode = "AOF"
    aof_config {
      append_fsync = "EVERY_SEC"
    }
  }

  # this block require google_network_connectivity_service_connection_policy
  # to ensure auto create private ip (the endpoint) by the service connection policy
  # the google_network_connectivity_service_connection_policy resource is hosting in GCP/network/main.tf
  # this block cannot change after resource created
  # ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/memorystore_instance#desired_auto_created_endpoints-1
  desired_auto_created_endpoints {
    project_id = var.project_id
    network    = data.google_compute_network.network.id
  }

  deletion_protection_enabled = false
}
