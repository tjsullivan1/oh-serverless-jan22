resource "random_string" "suffix" {
  length  = 4
  lower   = true
  upper   = false
  special = false
  number  = true
}

locals {
  challenge_name = "challenge32"
  kv_id          = "/subscriptions/8b63fe10-d76a-4f8f-81ce-7a5a8b911779/resourceGroups/rg-core-it/providers/Microsoft.KeyVault/vaults/tjs-kv-premium"
}

data "azurerm_key_vault" "challenge3" {
  name                = "tjs-kv-premium"
  resource_group_name = "rg-core-it"
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
  kind                = "linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
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
  version                    = "~4"

  site_config {
    linux_fx_version = "python|3.9"
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    AZURE_COSMOSDB_CONNECTION_STRING      = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.challenge3.vault_uri}secrets/${azurerm_key_vault_secret.cosmos_conn_string.name})"
    AZURE_COSMOSDB_DATABASE_NAME          = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.challenge3.vault_uri}secrets/${azurerm_key_vault_secret.cosmos_sql_db_name.name})"
    AZURE_COSMOSDB_COLLECTION             = "@Microsoft.KeyVault(SecretUri=${data.azurerm_key_vault.challenge3.vault_uri}secrets/${azurerm_key_vault_secret.cosmos_sql_collection.name})"
    APPINSIGHTS_INSTRUMENTATIONKEY        = azurerm_application_insights.challenge3.instrumentation_key
    APPLICATIONINSIGHTS_CONNECTION_STRING = azurerm_application_insights.challenge3.connection_string
    # SCM_DO_BUILD_DURING_DEPLOYMENT = "true"
    # ENABLE_ORYX_BUILD = "true"
  }
}

resource "azurerm_cosmosdb_account" "challenge3" {
  name                = "cosmos-${local.challenge_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rgch3.location
  resource_group_name = azurerm_resource_group.rgch3.name
  offer_type          = "Standard"

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 300
    max_staleness_prefix    = 100000
  }

  geo_location {
    location          = azurerm_resource_group.rg.location
    failover_priority = 0
  }

}

resource "azurerm_cosmosdb_sql_database" "challenge3" {
  name                = "cosmos-sql"
  account_name        = azurerm_cosmosdb_account.challenge3.name
  resource_group_name = azurerm_resource_group.rgch3.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "challenge3" {
  name                  = "Items"
  account_name          = azurerm_cosmosdb_account.challenge3.name
  resource_group_name   = azurerm_resource_group.rgch3.name
  database_name         = azurerm_cosmosdb_sql_database.challenge3.name
  partition_key_path    = "/definition/id"
  partition_key_version = 1
}

resource "azurerm_key_vault_secret" "cosmos_conn_string" {
  name         = "AZURE-COSMOSDB-CONNECTION-STRING${local.challenge_name}"
  value        = azurerm_cosmosdb_account.challenge3.connection_strings[0]
  key_vault_id = local.kv_id
}

resource "azurerm_key_vault_secret" "cosmos_sql_db_name" {
  name         = "AZURE-COSMOSDB-DATABASE-NAME${local.challenge_name}"
  value        = azurerm_cosmosdb_sql_database.challenge3.name
  key_vault_id = local.kv_id
}

resource "azurerm_key_vault_secret" "cosmos_sql_collection" {
  name         = "AZURE-COSMOSDB-COLLECTION${local.challenge_name}"
  value        = azurerm_cosmosdb_sql_container.challenge3.name
  key_vault_id = local.kv_id
}

resource "azurerm_key_vault_access_policy" "myfunctionchallenge3" {
  key_vault_id = local.kv_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  object_id = azurerm_function_app.challenge3.identity.0.principal_id

  secret_permissions = [
    "get",
  ]
}

data "azurerm_log_analytics_workspace" "la-tjs" {
  name                = "la-tjs-01"
  resource_group_name = "rg-logs"
}

resource "azurerm_application_insights" "challenge3" {
  name                = "aai-${local.challenge_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.rgch3.location
  resource_group_name = azurerm_resource_group.rgch3.name
  workspace_id        = data.azurerm_log_analytics_workspace.la-tjs.id
  application_type    = "web"
}
