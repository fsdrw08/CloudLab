terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.57.0"
    }
    google = {
      source  = "hashicorp/google"
      version = ">= 7.14.1"
    }
  }
}
