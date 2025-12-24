resource "google_compute_network" "network" {
  project                 = var.project_id
  name                    = var.vpc_name
  auto_create_subnetworks = true
  mtu                     = 1460
  bgp_best_path_selection_mode = "STANDARD"
  routing_mode = "REGIONAL"
}