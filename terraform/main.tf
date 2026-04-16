locals {
  name_suffix = "${var.prefix}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "this" {
  name     = "rg-test-${local.name_suffix}"
  location = var.location
  tags     = var.tags
}
