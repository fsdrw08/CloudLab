variable "project_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

variable "subnets" {
  type = list(object({
    name          = string
    region        = string
    ip_cidr_range = string
  }))
}

variable "psc_policies" {
  type = list(object({
    name          = string
    location      = string
    service_class = string
    subnetworks   = list(string)
  }))
}
