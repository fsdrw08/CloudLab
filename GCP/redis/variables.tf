variable "project_id" {
  type = string
  description = "The GCP project ID where the Redis instance will be created."
}

variable "vpc_name" {
  type = string
  description = "The name of the VPC network to authorize the Redis instance to."
}

variable "region" {
  type = string
}

variable "name" {
  type        = string
  description = "The name of the Redis instance."
}
