resource_group_name = "rg-<band><region><business>-d365-001"

network = {
  resource_group  = "Azure_SharedServices_HK_Production"
  virtual_network = "Azure_SharedServices_HK_Production_VNET"
  subnet          = "Azure_SharedServices_HK_Production_VNET"
}

vm = {
  name = "<band><region>D365-P01"
  size = "Standard_E16-8ds_v6"
}
