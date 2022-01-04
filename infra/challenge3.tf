resource "random_string" "suffix" {
  length           = 4
}

locals {
  challenge_name = "challenge3"
}


resource "azurerm_resource_group" "rgch3" {
  name     = "rg-tjs-oh-${local.challenge_name}"
  location = "eastus"
}

resource "azurerm_storage_account" "stafach3" {
  name                     = "stafa${local.challenge_name}"
  resource_group_name      = azurerm_resource_group.rgch3.name
  location                 = azurerm_resource_group.rgch3.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "aspch3" {
  name                = "asp-tjs-${local.challenge_name}"
  location            = azurerm_resource_group.rgch3.location
  resource_group_name = azurerm_resource_group.rgch3.name
  kind                = "functionapp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "challenge3" {
  name                       = "${local.challenge_name}-${random_string.suffix.result}"
  location                   = azurerm_resource_group.rgch3.location
  resource_group_name        = azurerm_resource_group.rgch3.name
  app_service_plan_id        = azurerm_app_service_plan.aspch3.id
  storage_account_name       = azurerm_storage_account.stafach3.name
  storage_account_access_key = azurerm_storage_account.stafach3.primary_access_key
  os_type                    = "linux"
  version                    = "~3"
}
