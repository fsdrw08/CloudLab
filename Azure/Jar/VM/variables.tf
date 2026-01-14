variable "resource_group_name" {
  type = string
}

variable "network" {
  type = object({
    resource_group  = string
    virtual_network = string
    subnet          = string
  })
}

variable "vm" {
  type = object({
    name = string
    size = string

  })
}
