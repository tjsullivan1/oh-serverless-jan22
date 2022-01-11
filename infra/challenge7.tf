locals {
  c7_suffix       = "awe3"
  challenge_name7 = "challenge7"
}

data "azurerm_eventhub_namespace_authorization_rule" "c7" {
  name                = "RootManageSharedAccessKey"
  resource_group_name = "rg-challenge7-awe3"
  namespace_name      = "eh-ohc7-awe3"
}


resource "azurerm_resource_group" "rgch7" {
  name     = "rg-tjs-oh-${local.challenge_name7}-${local.c7_suffix}"
  location = "eastus"
}

resource "azurerm_storage_account" "stafach7" {
  name                     = "stafa${local.challenge_name7}${local.c7_suffix}"
  resource_group_name      = azurerm_resource_group.rgch7.name
  location                 = azurerm_resource_group.rgch7.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "aspch7" {
  name                = "asp-tjs-${local.challenge_name7}"
  location            = azurerm_resource_group.rgch7.location
  resource_group_name = azurerm_resource_group.rgch7.name
  kind                = "linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "challenge7" {
  name                       = "${local.challenge_name7}-${local.c7_suffix}"
  location                   = azurerm_resource_group.rgch7.location
  resource_group_name        = azurerm_resource_group.rgch7.name
  app_service_plan_id        = azurerm_app_service_plan.aspch7.id
  storage_account_name       = azurerm_storage_account.stafach7.name
  storage_account_access_key = azurerm_storage_account.stafach7.primary_access_key
  os_type                    = "linux"
  version                    = "~4"

  site_config {
    linux_fx_version = "python|3.9"
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    ehohc7awe3_RootManageSharedAccessKey_EVENTHUB = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.challenge3.vault_uri}secrets/${azurerm_key_vault_secret.event_hub_conn.name})"
    AzureCosmosDBConnectionString                 = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.challenge3.vault_uri}secrets/${azurerm_key_vault_secret.cosmos_conn_string.name})"
    APPINSIGHTS_INSTRUMENTATIONKEY                = azurerm_application_insights.challenge3.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING         = azurerm_application_insights.challenge3.connection_string
    # SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    # ENABLE_ORYX_BUILD = "true"
  }
}



resource "azurerm_key_vault_secret" "event_hub_conn" {
  name         = "ehohc7awe3_RootManageSharedAccessKey_EVENTHUB"
  value        = data.azurerm_eventhub_namespace_authorization_rule.c7.primary_connection_string
  key_vault_id = local.kv_id
}

resource "azurerm_key_vault_access_policy" "myfunctionchallenge7" {
  key_vault_id = local.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id = azurerm_function_app.challenge7.identity.0.principal_id

  secret_permissions = [
    "get",
  ]
}
