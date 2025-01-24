terraform {
  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = ">=1.3.0"
    }
  }
}

provider "azuredevops" {
  org_service_url = var.org_service_url
}
