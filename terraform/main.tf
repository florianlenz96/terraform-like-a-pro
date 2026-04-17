locals {
  name_suffix = "${var.prefix}-${var.environment}"
}

resource "azurerm_resource_group" "main" {
  name     = "rg-${local.name_suffix}"
  location = var.location
  tags     = var.tags
}

resource "azurerm_resource_group" "this" {
  name = "this-test"
  location = var.location
  tags     = var.tags
}