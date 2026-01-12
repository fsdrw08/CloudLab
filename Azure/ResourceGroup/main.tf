resource "azurerm_resource_group" "resource_group" {
  name     = var.resource_group.name
  location = var.resource_group.location
}
