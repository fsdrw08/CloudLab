resource_group_name = "Azure_SharedServices_<region>_Production"


virtual_network = {
  name          = "Azure_SharedServices_<region>_Production_VNET"
  address_space = ["10.130.0.0/16"]
  dGFncyA9IHsKICAgICJBcHBsaWNhdGlvbiIgICAgICA9ICJEb21haW4gQ29udHJvbGxlciBhbmQgQXBwIER5bmFtaWMiCiAgICAiQXBwbGljYXRpb25OYW1lIiAgPSAiSW5mcmEiCiAgICAiQmFubmVyLUxvY2F0aW9uIiAgPSAiSlJHSEsiCiAgICAiQnVzaW5lc3MgVW5pdCIgICAgPSAiSlJHSEsiCiAgICAiRW52IiAgICAgICAgICAgICAgPSAiUFJPRCIKICAgICJTZXJ2aW5nIENhdGVnb3J5IiA9ICJJbmZyYSIKICAgICJUYWdnaW5nIFN0YXR1cyIgICA9ICJvayIKICAgICJvd25lciIgICAgICAgICAgICA9ICJ3aW5nIgogIH0=
}

subnets = [
  {
    name             = "Azure_SharedServices_<region>_Production_VNET"
    address_prefixes = ["10.130.0.0/24"]
    service_endpoints = ["Microsoft.Sql"]
  },
]
