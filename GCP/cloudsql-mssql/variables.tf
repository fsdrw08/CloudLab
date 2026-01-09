variable "project_id" {
  type        = string
  description = "The project to run tests against"
}

variable "vpc_name" {
  type = string
}

variable "subnet" {
  type = object({
    name   = string
    region = string
  })
}

variable "sql_instance" {
  type = object({
    name             = string
    database_version = string
    tier             = string
    authorized_networks = list(object({
      name  = optional(string, null)
      value = string
    }))
  })
}

variable "sql_users" {
  type = list(object({
    name     = string
    password = optional(string, null)
  }))
}
