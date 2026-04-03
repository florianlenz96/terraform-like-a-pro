# Storage account backing the Function App
resource "azurerm_storage_account" "functions" {
  name                     = "st${var.prefix}fn${var.environment}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  min_tls_version                 = "TLS1_2"

  tags = var.tags
}

# Blob container where Flex Consumption stores deployment packages
resource "azurerm_storage_container" "deployment" {
  name               = "deployments"
  storage_account_id = azurerm_storage_account.functions.id
}

# Flex Consumption — no service plan needed; billing is per-execution
resource "azurerm_linux_function_app_flex_consumption" "api" {
  name                = "func-${local.name_suffix}-api"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  storage_container_type      = "blobContainer"
  storage_container_endpoint  = "${azurerm_storage_account.functions.primary_blob_endpoint}${azurerm_storage_container.deployment.name}"
  storage_authentication_type = "StorageAccountConnectionString"
  storage_access_key          = azurerm_storage_account.functions.primary_access_key

  runtime_name    = "node"
  runtime_version = "20"

  https_only = true

  maximum_instance_count = 10
  instance_memory_in_mb  = 2048

  site_config {}

  app_settings = {
    ENVIRONMENT = var.environment
  }

  tags = var.tags
}

