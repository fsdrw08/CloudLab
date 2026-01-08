resource "google_compute_network" "network" {
  project                      = var.project_id
  name                         = var.vpc_name
  auto_create_subnetworks      = false
  mtu                          = 1460
  bgp_best_path_selection_mode = "STANDARD"
  routing_mode                 = "GLOBAL"
}

# https://github.com/ksmin23/gcp-datastream-mysql-cdc-to-gcs/blob/bcbbf6f39b67335e02beddcec9dc98e145c94b5f/terraform/modules/network/vpc.tf#L91
# NOTE: This Private Service Access (PSA) configuration is a prerequisite for provisioning
# a Cloud SQL instance with a private IP. However, all actual client connections
# (from Datastream, GCE, etc.) will be made through a Private Service Connect (PSC)
# endpoint created in the 02-app-infra module for a more modern and flexible architecture.
resource "google_compute_global_address" "peering_ip_address" {
  name          = "vpc-peering-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.network.id
  project       = var.project_id
}

# required for cloud sql instance private ip
resource "google_service_networking_connection" "private_vpc_connection" {
  network = google_compute_network.network.id
  service = "servicenetworking.googleapis.com"
  # https://github.com/hashicorp/terraform-provider-google/issues/19908#issuecomment-2633443737
  deletion_policy         = "ABANDON"
  reserved_peering_ranges = [google_compute_global_address.peering_ip_address.name]
}

# required for memorystore private ip
resource "google_compute_subnetwork" "subnetwork" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }

  project = var.project_id
  network = google_compute_network.network.id
  region  = each.value.region

  name          = each.value.name
  ip_cidr_range = each.value.ip_cidr_range
}

# A service connection policy lets you authorize the specified service class to create a Private Service Connect connection between producer and consumer VPC networks.
# the policy means allow different service class (memorystore, cloudsql, etc.) to create a Private Service Connect connection between producer and consumer VPC networks.
# required for memorystore private ip, Role 2: Network Admin
# ref: https://docs.cloud.google.com/memorystore/docs/valkey/networking#networking_setup_guidance
resource "google_network_connectivity_service_connection_policy" "service_connection_policy" {
  for_each = {
    for policy in var.psc_policies : policy.name => policy
  }

  project       = var.project_id
  name          = each.value.name
  location      = each.value.location
  service_class = each.value.service_class
  network       = google_compute_network.network.id
  psc_config {
    subnetworks = [google_compute_subnetwork.subnetwork[each.value.subnetworks[0]].id]
  }
}
