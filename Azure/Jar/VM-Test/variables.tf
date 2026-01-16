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

variable "disks" {
  type = list(object({
    name                 = string
    create_option        = string
    storage_account_type = string
    disk_size_gb         = number
    # The Logical Unit Number of the Data Disk, which needs to be unique within the Virtual Machine
    lun = number
    # Specifies the caching requirements for this Data Disk, None, ReadOnly or ReadWrite
    caching = string
  }))
  default = []
}

variable "virtual_machine" {
  type = object({
    name = string
    size = string

  })
}

variable "virtual_machine_extensions" {
  type = list(object({
    name                 = string
    publisher            = string
    type                 = string
    type_handler_version = string
    settings             = optional(string, null)
    protected_settings   = optional(string, null)
    script               = optional(string, null)
    protected_script     = optional(string, null)
  }))
  default = []
}

variable "network_security_rules" {
  type = object({
    resource_group_name         = string
    network_security_group_name = string
    rules = list(object({
      name                   = string
      priority               = number
      direction              = string
      access                 = string
      protocol               = string
      source_address_prefix  = string
      source_port_range      = string
      destination_port_range = string
    }))
  })
}
