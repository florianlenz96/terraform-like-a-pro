terraform {
  required_version = ">= 1.7.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # Partial backend configuration.
  # The storage account name, container name, and key are injected at runtime:
  #   terraform init \
  #     -backend-config="storage_account_name=$TF_STATE_SA" \
  #     -backend-config="container_name=tfstate" \
  #     -backend-config="key=${ENVIRONMENT}.terraform.tfstate"
  backend "azurerm" {
    resource_group_name = "rg-terraform-backend"
  }
}

provider "azurerm" {
  features {}
}
