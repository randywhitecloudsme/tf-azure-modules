terraform {
  required_version = ">= 1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

module "app_service" {
  source = "../../"

  service_plan_name   = var.service_plan_name
  app_name            = var.app_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  os_type           = var.os_type
  sku_name          = var.sku_name
  application_stack = var.application_stack
  app_settings      = var.app_settings

  tags = var.tags
}
