# Storage account backing the Function App
resource "azurerm_storage_account" "functions" {
  name                     = "st${var.prefix}fn${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # No public blob access — blobs are private
  allow_nested_items_to_be_public = false

  https_traffic_only_enabled = true
  min_tls_version            = "TLS1_2"

  tags = var.tags
}

resource "azurerm_service_plan" "functions" {
  name                = "asp-${local.name_suffix}-fn"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "Y1" # Consumption plan

  tags = var.tags
}

resource "azurerm_linux_function_app" "api" {
  name                = "func-${local.name_suffix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_account_name       = azurerm_storage_account.functions.name
  storage_account_access_key = azurerm_storage_account.functions.primary_access_key
  service_plan_id            = azurerm_service_plan.functions.id

  https_only = true

  site_config {
    application_stack {
      node_version = "18"
    }

    cors {
      allowed_origins = ["https://portal.azure.com"]
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    ENVIRONMENT              = var.environment
    WEBSITE_RUN_FROM_PACKAGE = "1"
  }

  tags = var.tags
}
