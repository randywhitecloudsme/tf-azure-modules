resource "azurerm_kubernetes_cluster" "this" {
  name                              = var.name
  location                          = var.location
  resource_group_name               = var.resource_group_name
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  sku_tier                          = var.sku_tier
  workload_identity_enabled         = var.workload_identity_enabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled
  azure_policy_enabled              = var.azure_policy_enabled
  local_account_disabled            = var.local_account_disabled
  automatic_channel_upgrade         = var.automatic_channel_upgrade

  default_node_pool {
    name                = var.default_node_pool.name
    node_count          = lookup(var.default_node_pool, "node_count", null)
    vm_size             = var.default_node_pool.vm_size
    enable_auto_scaling = lookup(var.default_node_pool, "enable_auto_scaling", false)
    min_count           = lookup(var.default_node_pool, "min_count", null)
    max_count           = lookup(var.default_node_pool, "max_count", null)
    max_pods            = lookup(var.default_node_pool, "max_pods", null)
    os_disk_size_gb     = lookup(var.default_node_pool, "os_disk_size_gb", null)
    os_disk_type        = lookup(var.default_node_pool, "os_disk_type", "Managed")
    vnet_subnet_id      = lookup(var.default_node_pool, "vnet_subnet_id", null)
    zones               = lookup(var.default_node_pool, "zones", null)
    node_labels         = lookup(var.default_node_pool, "node_labels", {})
    node_taints         = lookup(var.default_node_pool, "node_taints", [])

    upgrade_settings {
      max_surge = lookup(var.default_node_pool, "max_surge", "10%")
    }
  }

  identity {
    type = var.identity_type
  }

  network_profile {
    network_plugin     = var.network_profile.network_plugin
    network_policy     = lookup(var.network_profile, "network_policy", null)
    dns_service_ip     = lookup(var.network_profile, "dns_service_ip", null)
    service_cidr       = lookup(var.network_profile, "service_cidr", null)
    load_balancer_sku  = lookup(var.network_profile, "load_balancer_sku", "standard")
    outbound_type      = lookup(var.network_profile, "outbound_type", "loadBalancer")
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_ad_rbac_enabled ? [1] : []

    content {
      managed                = true
      azure_rbac_enabled     = lookup(var.azure_ad_rbac_config, "azure_rbac_enabled", true)
      admin_group_object_ids = lookup(var.azure_ad_rbac_config, "admin_group_object_ids", [])
    }
  }

  dynamic "oms_agent" {
    for_each = var.log_analytics_workspace_id != null ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "microsoft_defender" {
    for_each = var.microsoft_defender_enabled ? [1] : []

    content {
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }

  dynamic "key_vault_secrets_provider" {
    for_each = var.key_vault_secrets_provider_enabled ? [1] : []

    content {
      secret_rotation_enabled  = var.secret_rotation_enabled
      secret_rotation_interval = var.secret_rotation_interval
    }
  }

  role_based_access_control_enabled = var.role_based_access_control_enabled

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Set to true for production
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  for_each = var.additional_node_pools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = lookup(each.value, "node_count", null)
  enable_auto_scaling   = lookup(each.value, "enable_auto_scaling", false)
  min_count             = lookup(each.value, "min_count", null)
  max_count             = lookup(each.value, "max_count", null)
  max_pods              = lookup(each.value, "max_pods", null)
  os_disk_size_gb       = lookup(each.value, "os_disk_size_gb", null)
  os_disk_type          = lookup(each.value, "os_disk_type", "Managed")
  vnet_subnet_id        = lookup(each.value, "vnet_subnet_id", null)
  zones                 = lookup(each.value, "zones", null)
  mode                  = lookup(each.value, "mode", "User")
  node_labels           = lookup(each.value, "node_labels", {})
  node_taints           = lookup(each.value, "node_taints", [])

  upgrade_settings {
    max_surge = lookup(each.value, "max_surge", "10%")
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [node_count]
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "kube-apiserver"
  }

  enabled_log {
    category = "kube-controller-manager"
  }

  enabled_log {
    category = "kube-scheduler"
  }

  enabled_log {
    category = "kube-audit"
  }

  enabled_log {
    category = "cluster-autoscaler"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
