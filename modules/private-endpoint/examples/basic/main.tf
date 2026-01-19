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

# Resource Group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "example" {
  name                = var.vnet_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = var.address_space
}

# Subnet for private endpoints
resource "azurerm_subnet" "pe" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = var.subnet_prefixes
}

# Storage Account
resource "azurerm_storage_account" "example" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public access for security
  public_network_access_enabled = false
}

# Private DNS Zone for blob storage
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.example.name
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-dns"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

# Private Endpoint for blob storage
module "private_endpoint" {
  source = "../../"

  name                = var.private_endpoint_name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  subnet_id                      = azurerm_subnet.pe.id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["blob"]

  # Automatic DNS integration
  private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
    Purpose     = "Example"
  }
}
