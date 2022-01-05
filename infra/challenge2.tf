locals {
  api_endpoint  = "GET_challenge2"
  function_name = "challenge22"
}

data "template_file" "workflow" {
  template = file("./logicapp.json")
}

variable "workflow_parameters" {
  description = "The parameters passed to the workflow"
  default     = {}
}

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
  kind                = "functionapp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_function_app" "challenge2" {
  name                       = local.function_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  app_service_plan_id        = azurerm_app_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.stafa.name
  storage_account_access_key = azurerm_storage_account.stafa.primary_access_key
  os_type                    = "linux"
  version                    = "~3"
}

resource "azurerm_logic_app_workflow" "workflow1" {
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  name                = "la-oh-2"
}

resource "azurerm_template_deployment" "workflow1" {
  depends_on = [azurerm_logic_app_workflow.workflow1]

  resource_group_name = azurerm_resource_group.rg.name
  parameters = merge({
    "workflows_functions_uri" = "https://${local.function_name}.azurewebsites.net/api/${local.api_endpoint}",
    "location"                = azurerm_resource_group.rg.location
  }, var.workflow_parameters)

  template_body = data.template_file.workflow.template

  name            = "terraform-logic-app-deploy"
  deployment_mode = "Incremental"
}