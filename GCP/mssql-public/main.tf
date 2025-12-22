/**
 * Copyright 2024 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

resource "random_password" "password" {
  length = 10
}

data "google_compute_network" "network" {
  name = var.vpc_name
}

module "mssql" {
  source  = "terraform-google-modules/sql-db/google//modules/mssql"
  version = "~> 26.0"

  name                 = var.name
  random_instance_name = true
  project_id           = var.project_id
  user_name            = "dbuser"
  user_password        = random_password.password.result

  tier = "db-custom-2-7680"
  database_version = "SQLSERVER_2019_STANDARD"
  region = var.region

  ip_configuration = {
    ipv4_enabled    = true
    private_network = data.google_compute_network.network.self_link
  }

  deletion_protection = false

  sql_server_audit_config = var.sql_server_audit_config

  insights_config = {
    query_plans_per_minute = 5
  }

}