resource "random_string" "suffix4" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  number  = true
}

locals {
  challenge4_name = "challenge4"
}

resource "azurerm_resource_group" "rg4" {
  name     = "rg-${local.challenge4_name}-${random_string.suffix.result}"
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
  name                = "apim-${local.challenge4_name}-${random_string.suffix.result}"
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
  resource_group_name   = azurerm_resource_group.rg4.name
  display_name          = "Mobile Applications"
  subscription_required = true
  approval_required     = false
  published             = true
  description           = "The Mobile Application requires access to all of the APIs. Each of them is required for different areas of the application’s UX. "
}

resource "azurerm_api_management_product" "internal" {
  product_id            = "internal-product"
  api_management_name   = azurerm_api_management.challenge4.name
  resource_group_name   = azurerm_resource_group.rg4.name
  display_name          = "Internal Users"
  subscription_required = true
  approval_required     = false
  published             = true
  description           = "The Internal business users use the APIs for reporting purposes. They need access to the product and rating information but shouldn’t be using the user operation or be able to create ratings."
}

resource "azurerm_api_management_product" "external" {
  product_id            = "external-product"
  api_management_name   = azurerm_api_management.challenge4.name
  resource_group_name   = azurerm_resource_group.rg4.name
  display_name          = "External Users"
  subscription_required = true
  approval_required     = false
  published             = true
  description           = "The External Partners use case is to be able to see products that BYFOC has to offer, so should only have the product operations exposed to them."
}

resource "azurerm_api_management_api" "GetProduct" {
  name                = "GetProduct"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "GetProduct"
  path                = "GetProduct"
  protocols           = ["https"]
}

resource "azurerm_api_management_api" "GetProducts" {
  name                = "GetProducts"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "GetProducts"
  path                = "GetProducts"
  protocols           = ["https"]
}

resource "azurerm_api_management_api" "GetUser" {
  name                = "GetUser"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "GetUser"
  path                = "GetUser"
  protocols           = ["https"]
}

resource "azurerm_api_management_api" "CreateRating" {
  name                = "CreateRating"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "CreateRating"
  path                = "CreateRating"
  protocols           = ["https"]
}

resource "azurerm_api_management_api" "GetRating" {
  name                = "GetRating"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "GetRating"
  path                = "GetRating"
  protocols           = ["https"]
}

resource "azurerm_api_management_api" "GetRatings" {
  name                = "GetRatings"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "GetRatings"
  path                = "GetRatings"
  protocols           = ["https"]
}

resource "azurerm_api_management_product_api" "mobileGetUser" {
  api_name            = azurerm_api_management_api.GetUser.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileGetProduct" {
  api_name            = azurerm_api_management_api.GetProduct.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileGetProducts" {
  api_name            = azurerm_api_management_api.GetProducts.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileCreateRating" {
  api_name            = azurerm_api_management_api.CreateRating.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileGetRating" {
  api_name            = azurerm_api_management_api.GetRating.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileGetRatings" {
  api_name            = azurerm_api_management_api.GetRatings.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "internalGetProduct" {
  api_name            = azurerm_api_management_api.GetProduct.name
  product_id          = azurerm_api_management_product.internal.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "internalGetProducts" {
  api_name            = azurerm_api_management_api.GetProducts.name
  product_id          = azurerm_api_management_product.internal.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "internalGetRating" {
  api_name            = azurerm_api_management_api.GetRating.name
  product_id          = azurerm_api_management_product.internal.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "internalGetRatings" {
  api_name            = azurerm_api_management_api.GetRatings.name
  product_id          = azurerm_api_management_product.internal.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "externalGetProduct" {
  api_name            = azurerm_api_management_api.GetProduct.name
  product_id          = azurerm_api_management_product.external.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "externalGetProducts" {
  api_name            = azurerm_api_management_api.GetProducts.name
  product_id          = azurerm_api_management_product.external.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}
