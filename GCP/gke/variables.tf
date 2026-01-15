variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnet" {
  type = object({
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

variable "dns_records" {
  type = list(object({
    resource_group_name = string
    zone_name           = string
    name                = string
    ttl                 = number
    records             = list(string)
  }))
}
