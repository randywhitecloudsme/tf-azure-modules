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
  name     = "production-aks-rg"
  location = "eastus"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "production-aks-law"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

module "aks" {
  source = "../../"

  name                = "production-aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "production-aks"
  kubernetes_version  = "1.28"

  # Private cluster configuration
  private_cluster_enabled = true
  sku_tier                = "Standard"

  # Workload identity
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  # Azure Policy
  azure_policy_enabled = true

  # Security
  local_account_disabled    = true
  automatic_channel_upgrade = "stable"

  default_node_pool = {
    name                = "system"
    vm_size             = "Standard_D2s_v3"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    os_disk_size_gb     = 100
    os_disk_type        = "Managed"
    zones               = ["1", "2", "3"]
    max_surge           = "33%"
    node_labels = {
      "nodepool-type" = "system"
      "environment"   = "production"
    }
  }

  network_profile = {
    network_plugin    = "azure"
    network_policy    = "azure"
    service_cidr      = "10.0.0.0/16"
    dns_service_ip    = "10.0.0.10"
    load_balancer_sku = "standard"
    outbound_type     = "loadBalancer"
  }

  # Azure AD RBAC
  azure_ad_rbac_enabled = true
  azure_ad_rbac_config = {
    azure_rbac_enabled = true
    admin_group_object_ids = [
      # Add Azure AD group object IDs here
    ]
  }

  # Monitoring
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Microsoft Defender
  microsoft_defender_enabled = true

  # Key Vault integration
  key_vault_secrets_provider_enabled = true
  secret_rotation_enabled            = true
  secret_rotation_interval           = "2m"

  # Additional node pools
  additional_node_pools = {
    workload = {
      name                = "workload"
      vm_size             = "Standard_D4s_v3"
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 8
      os_disk_type        = "Ephemeral"
      zones               = ["1", "2", "3"]
      mode                = "User"
      max_surge           = "33%"
      node_labels = {
        "nodepool-type" = "workload"
        "environment"   = "production"
      }
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "Engineering"
  }
}
