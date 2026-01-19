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
  name     = "production-vmss-rg"
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
  name                = "production-vmss-law"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_lb" {
  name                = "production-lb"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                          = "frontend"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "backend-pool"
}

resource "azurerm_lb_probe" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "http-probe"
  protocol        = "Http"
  port            = 80
  request_path    = "/"
}

resource "azurerm_lb_rule" "example" {
  loadbalancer_id                = azurerm_lb.example.id
  name                           = "http-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.example.id
}

module "windows_vmss" {
  source = "../../"

  name                = "production-win-vmss"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Windows"
  sku                 = "Standard_D2s_v3"
  instances           = 3
  subnet_id           = azurerm_subnet.example.id

  admin_username = "azureadmin"
  admin_password = "P@ssw0rd1234!ComplexPassword" # Use Azure Key Vault in production

  source_image_reference = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }

  # High availability
  zones        = ["1", "2", "3"]
  zone_balance = true

  # Security
  encryption_at_host_enabled = true

  # OS Disk configuration
  os_disk_caching              = "ReadWrite"
  os_disk_storage_account_type = "Premium_LRS"

  # Upgrade configuration
  upgrade_mode                = "Rolling"
  enable_automatic_os_upgrade = false
  disable_automatic_rollback  = false

  rolling_upgrade_max_batch_instance_percent              = 20
  rolling_upgrade_max_unhealthy_instance_percent          = 20
  rolling_upgrade_max_unhealthy_upgraded_instance_percent = 20
  rolling_upgrade_pause_time_between_batches              = "PT30S"

  # Auto-repair
  enable_automatic_instance_repair       = true
  automatic_instance_repair_grace_period = "PT30M"
  health_probe_id                        = azurerm_lb_probe.example.id

  # Load balancer integration
  load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.example.id]

  # Autoscaling
  enable_autoscaling         = true
  autoscale_minimum_capacity = 3
  autoscale_default_capacity = 5
  autoscale_maximum_capacity = 15

  autoscale_rules = [
    {
      metric_name      = "Percentage CPU"
      time_grain       = "PT1M"
      statistic        = "Average"
      time_window      = "PT5M"
      time_aggregation = "Average"
      operator         = "GreaterThan"
      threshold        = 75
      scale_direction  = "Increase"
      scale_type       = "ChangeCount"
      scale_value      = "2"
      cooldown         = "PT5M"
    },
    {
      metric_name      = "Percentage CPU"
      time_grain       = "PT1M"
      statistic        = "Average"
      time_window      = "PT5M"
      time_aggregation = "Average"
      operator         = "LessThan"
      threshold        = 25
      scale_direction  = "Decrease"
      scale_type       = "ChangeCount"
      scale_value      = "1"
      cooldown         = "PT5M"
    }
  ]

  autoscale_notification_custom_emails = ["ops@example.com"]

  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT"
  }
}
