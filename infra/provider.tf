terraform {
  required_version = "~> 1.1.0"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 2.72.0"
    }
    random = {
      source  = "registry.terraform.io/hashicorp/random"
      version = "~> 3.1.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-core-it"
    storage_account_name = "tjscentralstore"
    container_name       = "tfstate"
    key                  = "oh-serverless/terraform.tfstate"
  }
}

provider "azurerm" {
  skip_provider_registration = false
  features {}
}


data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}
