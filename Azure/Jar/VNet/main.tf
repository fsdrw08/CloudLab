data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  address_space       = var.virtual_network.address_space
  tags                = var.virtual_network.tags
}

resource "azurerm_subnet" "subnets" {
  for_each = {
    for subnet in var.subnets : subnet.name => subnet
  }

  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  name                 = each.value.name
  address_prefixes     = each.value.address_prefixes
  service_endpoints    = each.value.service_endpoints
}
