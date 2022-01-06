resource "random_string" "suffix4" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  number  = true
}

locals {
  challenge_name = "challenge4"
}

resource "azurerm_resource_group" "rg4" {
  name     = "rg-${local.challenge_name}-${random_string.suffix.result}"
  location = "East US"
}

##
# This is the query needed to show the request stable that they request
# // Request count trend
# // Chart Request count over the last day.
# // To create an alert for this query, click '+ New alert rule'
# requests
# | where timestamp > ago(1h)
# | summarize RequestCount=sum(itemCount), AverageRequestTime=avg(duration) by name


resource "azurerm_api_management" "challenge4" {
  name                = "apim-${local.challenge_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rg4.location
  resource_group_name = azurerm_resource_group.rg4.name
  publisher_name      = "Sullivan Enterprises"
  publisher_email     = "tim@sullivanenterprises.org"

  sku_name = "Developer_1"


  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_product" "mobile" {
  product_id            = "mobile-product"
  api_management_name   = azurerm_api_management.challenge4.name
  resource_group_name   = azurerm_resource_group.challenge4.name
  display_name          = "Mobile Applications"
  subscription_required = true
  approval_required     = true
  published             = true
}

resource "azurerm_api_management_product" "internal" {
  product_id            = "internal-product"
  api_management_name   = azurerm_api_management.challenge4.name
  resource_group_name   = azurerm_resource_group.challenge4.name
  display_name          = "Internal Users"
  subscription_required = true
  approval_required     = true
  published             = true
}

resource "azurerm_api_management_product" "external" {
  product_id            = "external-product"
  api_management_name   = azurerm_api_management.challenge4.name
  resource_group_name   = azurerm_resource_group.challenge4.name
  display_name          = "External Users"
  subscription_required = true
  approval_required     = true
  published             = true
}
