data "azurerm_resource_group" "resource_group" {
  name = var.resource_group_name
}

resource "azurerm_service_plan" "asp_phhkmid_uat_003" {
  resource_group_name = data.azurerm_resource_group.resource_group.name
  location            = data.azurerm_resource_group.resource_group.location
  name                = var.app_service_plan.name
  os_type             = var.app_service_plan.os_type
  sku_name            = var.app_service_plan.sku_name
}
