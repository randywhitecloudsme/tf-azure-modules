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
  name     = "production-vm-rg"
  location = "eastus"
}

resource "azurerm_virtual_network" "example" {
  name                = "production-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "production-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "production-vm-law"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "windows_vm" {
  source = "../../"

  name                = "production-win-vm"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Windows"
  vm_size             = "Standard_D4s_v3"
  subnet_id           = azurerm_subnet.example.id

  private_ip_address_allocation = "Static"
  private_ip_address            = "10.0.1.10"

  admin_username = "azureadmin"
  admin_password = "P@ssw0rd1234!ComplexPassword" # Use Azure Key Vault in production

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # High availability
  zone = "1"

  # Security
  encryption_at_host_enabled = true

  # OS Disk configuration
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"
  os_disk_size_gb              = 256

  # Data disks
  data_disks = {
    data1 = {
      disk_size_gb         = 512
      storage_account_type = "Premium_LRS"
      lun                  = 0
      caching              = "ReadOnly"
    }
    data2 = {
      disk_size_gb         = 1024
      storage_account_type = "Premium_LRS"
      lun                  = 1
      caching              = "None"
    }
  }

  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  enable_monitoring_agent    = true
  enable_dependency_agent    = true

  # Patch management
  patch_mode            = "AutomaticByPlatform"
  patch_assessment_mode = "AutomaticByPlatform"

  # Windows-specific
  enable_automatic_updates = true
  timezone                 = "Eastern Standard Time"

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT"
    Backup      = "Daily"
  }
}
