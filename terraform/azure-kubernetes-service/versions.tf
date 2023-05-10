terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.55"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.38"
    }
  }
}

provider "azurerm" {
  features {}
}
