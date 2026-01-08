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

variable "instance_name" {
  type        = string
  description = "The name for Cloud SQL instance"
}

variable "sql_users" {
  type = list(object({
    name     = string
    password = optional(string, null)
  }))
}
