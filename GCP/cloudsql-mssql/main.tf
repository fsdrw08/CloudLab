resource "random_password" "root_password" {
  length = 10
}

data "google_compute_network" "network" {
  name = var.vpc_name
  project = var.project_id
}

resource "google_sql_database_instance" "mssql_instance" {
  name             = var.sql_instance_name
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
  root_password = random_password.root_password.result

  deletion_protection = false
}

resource "random_password" "additional_password" {
  for_each = {
    for user in var.sql_users : user.name => user
  }

  length  = 32
  special = true

  lifecycle {
    ignore_changes = [
      special, length
    ]
  }
}

resource "google_sql_user" "sql_user" {
  for_each = {
    for user in var.sql_users : user.name => user
  }
  name       = each.key
  project    = var.project_id
  instance   = google_sql_database_instance.mssql_instance.name
  password   = coalesce(each.value.password, random_password.additional_password[each.key].result)
}