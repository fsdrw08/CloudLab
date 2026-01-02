
resource "random_password" "password" {
  length = 10
}

data "google_compute_network" "network" {
  name = var.vpc_name
  project = var.project_id
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "mssql-private-ip-address"
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

resource "google_sql_database_instance" "mssql_instance" {
  name             = var.name
  database_version = "SQLSERVER_2019_STANDARD"
  region           = var.region
  project          = var.project_id

  settings {
    tier = "db-custom-2-8192"

    ip_configuration {
      ipv4_enabled    = true
      private_network = data.google_compute_network.network.self_link
    }

  }
  
  deletion_protection = false

  depends_on = [google_service_networking_connection.private_vpc_connection]
}