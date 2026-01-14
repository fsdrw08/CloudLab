resource "azurerm_resource_group" "resource_group" {
  for_each = {
    for resource_group in var.resource_groups : resource_group.name => resource_group
  }
  name     = each.value.name
  location = each.value.location
}
