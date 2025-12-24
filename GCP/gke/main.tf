data "google_compute_network" "vpc" {
  project = var.project_id
  name = var.vpc_name
}

resource "" "name" {
  
}

resource "google_container_cluster" "gke" {
  project = var.project_id
  name     = var.gke_cluster_name
  location = var.location

  enable_autopilot = true
  allow_net_admin = true
  
  networking_mode = "VPC_NATIVE"
  
  network    = data.google_compute_network.vpc.self_link
  subnetwork = 

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

  vertical_pod_autoscaling {
    enabled = true
  }

  release_channel {
    channel = "REGULAR"
  }
}