resource_group_name = "rg-<band><region>-d365-001"


public_ip = {
  name              = "pip-nat-<band><region>-d365-001"
  allocation_method = "Static"
  sku               = "Standard"
}

nat_gateway = {
  name = "natg-<band><region>-d365-001"
  sku  = "Standard"
}
