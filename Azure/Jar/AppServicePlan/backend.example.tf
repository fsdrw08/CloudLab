# terraform {
#   # https://developer.hashicorp.com/terraform/language/backend/azurerm#microsoft-entra-id
#   backend "azurerm" {
#     ## The Access Key of the storage account is required to authenticate to the storage account data plane.
#     ## This can also be set via the ARM_ACCESS_KEY environment variable.
#     ## can get from `az storage account keys list --subscription <band><region>-uat-001 -g rg-<band><region><department>-uat-001 -n st<band><region><department>uat001`
#     access_key = "xxxxx"
#     ## The name of the storage account to write the state file blob to.
#     ## Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
#     storage_account_name = "st<band><region><department>uat001"
#     ## The name of the storage account container to write the state file blob to.
#     ## Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
#     container_name = "iac-tfstate"
#     ## The name of the blob within the storage account container to write the state file to.
#     ## Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
#     key = "asp-<band><region><function>-uat-003"
#   }
# }
