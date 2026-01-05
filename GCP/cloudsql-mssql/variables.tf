variable "project_id" {
  type        = string
  description = "The project to run tests against"
}

variable "region" {
  type = string
  default = "asia-east1"
}

variable "vpc_name" {
  type = string
}

variable "sql_instance_name" {
  type        = string
  description = "The name for Cloud SQL instance"
}

variable "sql_users" {
  type = list(object({
    name = string
    password = optional(string, null)
  }))
}