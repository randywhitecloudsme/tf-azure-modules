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
  name     = "production-ase-rg"
  location = "eastus2" # Zone redundancy supported region
}

resource "azurerm_virtual_network" "example" {
  name                = "production-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "ase" {
  name                 = "ase-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "Microsoft.Web.hostingEnvironments"

    service_delegation {
      name    = "Microsoft.Web/hostingEnvironments"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_network_security_group" "ase" {
  name                = "ase-nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "AllowManagementInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AppServiceManagement"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowHealthMonitoring"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowVnetInbound"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "ase" {
  subnet_id                 = azurerm_subnet.ase.id
  network_security_group_id = azurerm_network_security_group.ase.id
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "production-ase-law"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "ase" {
  source = "../../"

  name                         = "production-ase"
  resource_group_name          = azurerm_resource_group.example.name
  subnet_id                    = azurerm_subnet.ase.id
  virtual_network_id           = azurerm_virtual_network.example.id
  internal_load_balancing_mode = "Web, Publishing"
  zone_redundant               = true
  create_private_dns_zone      = true

  # Security settings
  cluster_settings = [
    {
      name  = "DisableTls1.0"
      value = "1"
    },
    {
      name  = "DisableTls1.1"
      value = "1"
    },
    {
      name  = "FrontEndSSLCipherSuiteOrder"
      value = "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384,TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
    },
    {
      name  = "InternalEncryption"
      value = "true"
    }
  ]

  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "Platform"
  }

  depends_on = [
    azurerm_subnet_network_security_group_association.ase
  ]
}
