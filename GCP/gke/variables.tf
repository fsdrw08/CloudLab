variable "project_id" {
  type = string
}

variable "vpc_name" {
  type    = string
}

variable "subnet" {
  type =  object({
    name       = string
    cidr_range = string
    secondary_ip_range = list(object({
      range_name    = string
      ip_cidr_range = string
    }))
  })
}

variable "gke_cluster_name" {
  type = string
}

variable "location" {
  type = string
}