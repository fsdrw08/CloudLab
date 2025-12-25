data "google_compute_network" "vpc" {
  project = var.project_id
  name = var.vpc_name
}

resource "google_compute_subnetwork" "subnet" {
  project = var.project_id
  network = data.google_compute_network.vpc.self_link
  region = var.location

  name = var.subnet.name
  ip_cidr_range = var.subnet.cidr_range
  dynamic "secondary_ip_range" {
    for_each = var.subnet.secondary_ip_range

    content {
      range_name    = secondary_ip_range.value.range_name
      ip_cidr_range = secondary_ip_range.value.ip_cidr_range
    }
  }
}

resource "google_container_cluster" "gke" {
  project = var.project_id
  name     = var.gke_cluster_name
  location = var.location

  enable_autopilot = true
  allow_net_admin = true
  
  networking_mode = "VPC_NATIVE"
  
  network    = data.google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.16.1.16/28"
    master_global_access_config {
      enabled = true
    }
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  release_channel {
    channel = "REGULAR"
  }

  deletion_protection = false
}