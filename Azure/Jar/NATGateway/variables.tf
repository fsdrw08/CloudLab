variable "resource_group_name" {
  type = string
}

variable "public_ip" {
  type = object({
    name              = string
    allocation_method = string
    sku               = string
  })
}

variable "nat_gateway" {
  type = object({
    name = string
    sku  = string
  })
}
