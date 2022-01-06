resource "random_string" "suffix6" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  number  = true
}

locals {
  challenge6_name = "challenge6"
}

resource "azurerm_resource_group" "rg6" {
  name     = "rg-${local.challenge6_name}-${random_string.suffix6.result}"
  location = "East US"
}

resource "azurerm_storage_account" "c6sa" {
  name                     = "sa${local.challenge6_name}${random_string.suffix6.result}"
  resource_group_name      = azurerm_resource_group.rg6.name
  location                 = azurerm_resource_group.rg6.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "c6sa" {
  name                  = "raw"
  storage_account_name  = azurerm_storage_account.c6sa.name
  container_access_type = "private"
}
