terraform {
  # https://developer.hashicorp.com/terraform/language/backend/azurerm#microsoft-entra-id
  backend "azurerm" {
    ## Set to true to use the Azure CLI session authenticate to the storage account data plane. 
    ## This can also be set via the ARM_USE_CLI environment variable.
    use_cli = true
    ## Set to true to use Microsoft Entra ID authentication to the storage account data plane. 
    ## This can also be set via the ARM_USE_AZUREAD environment variable.
    use_azuread_auth = true
    ## check tenant id by `az account list -o table`
    ## Can also be set via `ARM_TENANT_ID` environment variable.
    tenant_id = "xxx"
    ## The name of the storage account to write the state file blob to.
    ## Can be passed via `-backend-config=`"storage_account_name=<storage account name>"` in the `init` command.
    storage_account_name = "st<band><region><department>uat001"
    ## The name of the storage account container to write the state file blob to.
    ## Can be passed via `-backend-config=`"container_name=<container name>"` in the `init` command.
    container_name = "iac-tfstate"
    ## The name of the blob within the storage account container to write the state file to.
    ## Can be passed via `-backend-config=`"key=<blob key name>"` in the `init` command.
    key = "asp-<band><region><function>-uat-003"
  }
}
