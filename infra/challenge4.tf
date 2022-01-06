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

resource "azurerm_api_management_api" "products" {
  name                = "productsAPI"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "Products API"
  path                = "products"
  protocols           = ["https"]
  service_url         = "https://serverlessohapi.azurewebsites.net/api"
}


resource "azurerm_api_management_api" "users" {
  name                = "usersAPI"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "Users API"
  path                = "users"
  protocols           = ["https"]
  service_url         = "https://serverlessohapi.azurewebsites.net/api"
}


resource "azurerm_api_management_api" "ratings" {
  name                = "ratingsAPI"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "Ratings API"
  path                = "ratings"
  protocols           = ["https"]
  service_url         = "https://challenge32-53i8.azurewebsites.net/api"
}
resource "azurerm_api_management_api" "CreateRating" {
  name                = "CreateRating"
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  revision            = "1"
  display_name        = "CreateRating"
  path                = "CreateRating"
  protocols           = ["https"]
  service_url         = "https://challenge32-53i8.azurewebsites.net/api"
}

resource "azurerm_api_management_product_api" "mobileUsers" {
  api_name            = azurerm_api_management_api.users.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileProducts" {
  api_name            = azurerm_api_management_api.products.name
  product_id          = azurerm_api_management_product.mobile.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "mobileRatings" {
  api_name            = azurerm_api_management_api.ratings.name
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


resource "azurerm_api_management_product_api" "internalProducts" {
  api_name            = azurerm_api_management_api.products.name
  product_id          = azurerm_api_management_product.internal.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_product_api" "internalRatings" {
  api_name            = azurerm_api_management_api.ratings.name
  product_id          = azurerm_api_management_product.internal.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}


resource "azurerm_api_management_product_api" "externalProducts" {
  api_name            = azurerm_api_management_api.products.name
  product_id          = azurerm_api_management_product.external.product_id
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
}

resource "azurerm_api_management_api_operation" "createRating" {
  operation_id        = "createRating"
  api_name            = azurerm_api_management_api.CreateRating.name
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  display_name        = "Create Rating"
  method              = "POST"
  url_template        = "/CreateRating"
  description         = "This can only be done by the logged in user."

  response {
    status_code = 200
  }
}

resource "azurerm_api_management_api_operation" "getRating" {
  operation_id        = "getRating"
  api_name            = azurerm_api_management_api.ratings.name
  api_management_name = azurerm_api_management.challenge4.name
  resource_group_name = azurerm_resource_group.rg4.name
  display_name        = "Get Rating"
  method              = "GET"
  url_template        = "/GetRating"
  description         = "This can only be done by the logged in user."

  response {
    status_code = 200
  }
}
