terraform {
  required_version = "~> 1.1.0"
  required_providers {
    azurerm = {
      source  = "registry.terraform.io/hashicorp/azurerm"
      version = "> 2.72.0"
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

resource "azurerm_resource_group" "rg" {
  name     = "rg-tjs-oh-challenge2"
  location = "eastus"
}

resource "azurerm_storage_account" "stafa" {
  name                     = "stafatjs"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "asp" {
  name                = "asp-tjs-challenge2"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "challenge2" {
  name                       = "challenge2"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.namegh
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.stafa.name
  storage_account_access_key = azurerm_storage_account.stafa.primary_access_key
  os_type                    = "linux"
  version                    = "~3"
}