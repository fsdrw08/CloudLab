variable "resource_group_name" {
  type = string
}

variable "virtual_network" {
  type = object({
    name          = string
    address_space = list(string)
    tags          = map(string)
  })
}

variable "subnets" {
  type = list(object({
    name              = string
    address_prefixes  = list(string)
    service_endpoints = list(string)
  }))
}
