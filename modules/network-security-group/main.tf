resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

resource "azurerm_network_security_rule" "this" {
  for_each = var.security_rules

  name                         = each.value.name
  priority                     = each.value.priority
  direction                    = each.value.direction
  access                       = each.value.access
  protocol                     = each.value.protocol
  source_port_range            = lookup(each.value, "source_port_range", null)
  source_port_ranges           = lookup(each.value, "source_port_ranges", null)
  destination_port_range       = lookup(each.value, "destination_port_range", null)
  destination_port_ranges      = lookup(each.value, "destination_port_ranges", null)
  source_address_prefix        = lookup(each.value, "source_address_prefix", null)
  source_address_prefixes      = lookup(each.value, "source_address_prefixes", null)
  destination_address_prefix   = lookup(each.value, "destination_address_prefix", null)
  destination_address_prefixes = lookup(each.value, "destination_address_prefixes", null)
  resource_group_name          = var.resource_group_name
  network_security_group_name  = azurerm_network_security_group.this.name
  description                  = lookup(each.value, "description", null)

  source_application_security_group_ids      = lookup(each.value, "source_application_security_group_ids", null)
  destination_application_security_group_ids = lookup(each.value, "destination_application_security_group_ids", null)
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each = var.subnet_associations

  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}

resource "azurerm_network_interface_security_group_association" "this" {
  for_each = var.network_interface_associations

  network_interface_id      = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}

# NSG Flow Logs (requires Network Watcher and Storage Account)
resource "azurerm_network_watcher_flow_log" "this" {
  count = var.enable_flow_logs ? 1 : 0

  name                 = "${var.name}-flowlog"
  network_watcher_name = var.network_watcher_name
  resource_group_name  = var.network_watcher_resource_group_name
  enabled              = true

  network_security_group_id = azurerm_network_security_group.this.id
  storage_account_id        = var.flow_log_storage_account_id
  version                   = var.flow_log_version

  retention_policy {
    enabled = var.flow_log_retention_enabled
    days    = var.flow_log_retention_days
  }

  dynamic "traffic_analytics" {
    for_each = var.enable_traffic_analytics ? [1] : []

    content {
      enabled               = true
      workspace_id          = var.log_analytics_workspace_id
      workspace_region      = var.log_analytics_workspace_location
      workspace_resource_id = var.log_analytics_workspace_resource_id
      interval_in_minutes   = var.traffic_analytics_interval
    }
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_network_security_group.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories

    content {
      category = enabled_log.value
    }
  }

  lifecycle {
    ignore_changes = [
      log_analytics_destination_type
    ]
  }
}
