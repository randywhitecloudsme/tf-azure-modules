resource "azurerm_app_service_environment_v3" "this" {
  name                         = var.name
  resource_group_name          = var.resource_group_name
  subnet_id                    = var.subnet_id
  internal_load_balancing_mode = var.internal_load_balancing_mode
  zone_redundant               = var.zone_redundant

  dynamic "cluster_setting" {
    for_each = var.cluster_settings

    content {
      name  = cluster_setting.value.name
      value = cluster_setting.value.value
    }
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_app_service_environment_v3.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceEnvironmentPlatformLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Private DNS Zone for Internal ASE
resource "azurerm_private_dns_zone" "ase" {
  count = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? 1 : 0

  name                = "${var.name}.appserviceenvironment.net"
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "ase" {
  count = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? 1 : 0

  name                  = "${var.name}-vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.ase[0].name
  virtual_network_id    = var.virtual_network_id

  tags = var.tags
}

# A Record for Internal Load Balancer
resource "azurerm_private_dns_a_record" "ase_wildcard" {
  count = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? 1 : 0

  name                = "*"
  zone_name           = azurerm_private_dns_zone.ase[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses[0]]

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "ase_root" {
  count = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? 1 : 0

  name                = "@"
  zone_name           = azurerm_private_dns_zone.ase[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses[0]]

  tags = var.tags
}

resource "azurerm_private_dns_a_record" "ase_scm" {
  count = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? 1 : 0

  name                = "*.scm"
  zone_name           = azurerm_private_dns_zone.ase[0].name
  resource_group_name = var.resource_group_name
  ttl                 = 300
  records             = [azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses[0]]

  tags = var.tags
}
