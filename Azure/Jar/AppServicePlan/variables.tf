variable "resource_group_name" {
  description = "The name of the resource group to create the App Service Plan in."
  type        = string
}

variable "app_service_plan" {
  type = object({
    name     = string
    os_type  = string
    sku_name = string
  })
}
