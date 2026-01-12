resource "random_password" "root_password" {
  length = 10
}

data "google_compute_network" "network" {
  name    = var.vpc_name
  project = var.project_id
}

data "google_compute_subnetwork" "subnetwork" {
  project = var.project_id
  name    = var.subnet.name
  region  = var.subnet.region
}

resource "google_sql_database_instance" "mssql_instance" {
  name             = var.sql_instance.name
  database_version = var.sql_instance.database_version
  region           = data.google_compute_subnetwork.subnetwork.region
  project          = var.project_id

  settings {
    tier = var.sql_instance.tier

    ip_configuration {
      # ipv4 means public ip
      ipv4_enabled    = true
      private_network = data.google_compute_network.network.self_link

      # use private service connection to create endpoint in target subnet
      # this require private service connection to be enabled in VPC network
      # check GCP/network/terraform.example.tfvars
      # https://docs.cloud.google.com/sql/docs/sqlserver/private-ip?authuser=1&_gl=1*121b8t3*_ga*MTEzOTM5NjIzMS4xNzU2MTk3NTA1*_ga_WH2QY8WWF5*czE3Njc4NjA0NzAkbzQxJGcxJHQxNzY3ODY0OTEyJGozOCRsMCRoMA..#requirements_for_private_ip
      # https://docs.cloud.google.com/sql/docs/sqlserver/configure-private-service-connect
      psc_config {
        psc_enabled               = true
        allowed_consumer_projects = [var.project_id]
        psc_auto_connections {
          consumer_service_project_id = var.project_id
          consumer_network            = data.google_compute_network.network.id
        }
      }

      dynamic "authorized_networks" {
        for_each = var.sql_instance.authorized_networks
        iterator = cidr
        content {
          name  = cidr.value.name
          value = cidr.value.value
        }
      }

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
  name     = each.key
  project  = var.project_id
  instance = google_sql_database_instance.mssql_instance.name
  password = coalesce(each.value.password, random_password.additional_password[each.key].result)

  lifecycle {
    # Reference the trigger resource
    replace_triggered_by = [
      google_sql_database_instance.mssql_instance.self_link
    ]
  }
}
