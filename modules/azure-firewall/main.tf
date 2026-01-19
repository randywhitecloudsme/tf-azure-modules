# Public IP for Azure Firewall
resource "azurerm_public_ip" "this" {
  count = var.create_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

# Azure Firewall
resource "azurerm_firewall" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = var.firewall_policy_id
  dns_servers         = var.dns_servers
  private_ip_ranges   = var.private_ip_ranges
  threat_intel_mode   = var.threat_intel_mode
  zones               = var.availability_zones
  tags                = var.tags

  ip_configuration {
    name                 = "ip-configuration"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.create_public_ip ? azurerm_public_ip.this[0].id : var.public_ip_address_id
  }

  dynamic "management_ip_configuration" {
    for_each = var.management_ip_configuration != null ? [var.management_ip_configuration] : []

    content {
      name                 = management_ip_configuration.value.name
      subnet_id            = management_ip_configuration.value.subnet_id
      public_ip_address_id = management_ip_configuration.value.public_ip_address_id
    }
  }

  dynamic "virtual_hub" {
    for_each = var.virtual_hub != null ? [var.virtual_hub] : []

    content {
      virtual_hub_id  = virtual_hub.value.virtual_hub_id
      public_ip_count = lookup(virtual_hub.value, "public_ip_count", 1)
    }
  }

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Firewall Policy (if not provided)
resource "azurerm_firewall_policy" "this" {
  count = var.create_firewall_policy ? 1 : 0

  name                     = "${var.name}-policy"
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.sku_tier
  threat_intelligence_mode = var.threat_intel_mode
  dns {
    proxy_enabled = var.dns_proxy_enabled
    servers       = var.dns_servers
  }

  dynamic "threat_intelligence_allowlist" {
    for_each = var.threat_intelligence_allowlist != null ? [var.threat_intelligence_allowlist] : []

    content {
      ip_addresses = lookup(threat_intelligence_allowlist.value, "ip_addresses", [])
      fqdns        = lookup(threat_intelligence_allowlist.value, "fqdns", [])
    }
  }

  dynamic "intrusion_detection" {
    for_each = var.intrusion_detection != null ? [var.intrusion_detection] : []

    content {
      mode = intrusion_detection.value.mode

      dynamic "signature_overrides" {
        for_each = lookup(intrusion_detection.value, "signature_overrides", [])

        content {
          id    = signature_overrides.value.id
          state = signature_overrides.value.state
        }
      }

      dynamic "traffic_bypass" {
        for_each = lookup(intrusion_detection.value, "traffic_bypass", [])

        content {
          name                  = traffic_bypass.value.name
          protocol              = traffic_bypass.value.protocol
          description           = lookup(traffic_bypass.value, "description", null)
          destination_addresses = lookup(traffic_bypass.value, "destination_addresses", null)
          destination_ports     = lookup(traffic_bypass.value, "destination_ports", null)
          source_addresses      = lookup(traffic_bypass.value, "source_addresses", null)
          source_ports          = lookup(traffic_bypass.value, "source_ports", null)
        }
      }
    }
  }

  tags = var.tags
}

# Firewall Policy Rule Collection Groups
resource "azurerm_firewall_policy_rule_collection_group" "this" {
  for_each = var.rule_collection_groups

  name               = each.value.name
  firewall_policy_id = var.create_firewall_policy ? azurerm_firewall_policy.this[0].id : var.firewall_policy_id
  priority           = each.value.priority

  dynamic "application_rule_collection" {
    for_each = lookup(each.value, "application_rule_collections", [])

    content {
      name     = application_rule_collection.value.name
      priority = application_rule_collection.value.priority
      action   = application_rule_collection.value.action

      dynamic "rule" {
        for_each = application_rule_collection.value.rules

        content {
          name        = rule.value.name
          description = lookup(rule.value, "description", null)

          protocols {
            type = rule.value.protocols.type
            port = rule.value.protocols.port
          }

          source_addresses      = lookup(rule.value, "source_addresses", null)
          source_ip_groups      = lookup(rule.value, "source_ip_groups", null)
          destination_fqdns     = lookup(rule.value, "destination_fqdns", null)
          destination_fqdn_tags = lookup(rule.value, "destination_fqdn_tags", null)
        }
      }
    }
  }

  dynamic "network_rule_collection" {
    for_each = lookup(each.value, "network_rule_collections", [])

    content {
      name     = network_rule_collection.value.name
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules

        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          source_addresses      = lookup(rule.value, "source_addresses", null)
          source_ip_groups      = lookup(rule.value, "source_ip_groups", null)
          destination_addresses = lookup(rule.value, "destination_addresses", null)
          destination_ip_groups = lookup(rule.value, "destination_ip_groups", null)
          destination_fqdns     = lookup(rule.value, "destination_fqdns", null)
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "nat_rule_collection" {
    for_each = lookup(each.value, "nat_rule_collections", [])

    content {
      name     = nat_rule_collection.value.name
      priority = nat_rule_collection.value.priority
      action   = nat_rule_collection.value.action

      dynamic "rule" {
        for_each = nat_rule_collection.value.rules

        content {
          name                = rule.value.name
          protocols           = rule.value.protocols
          source_addresses    = lookup(rule.value, "source_addresses", null)
          source_ip_groups    = lookup(rule.value, "source_ip_groups", null)
          destination_address = rule.value.destination_address
          destination_ports   = rule.value.destination_ports
          translated_address  = lookup(rule.value, "translated_address", null)
          translated_fqdn     = lookup(rule.value, "translated_fqdn", null)
          translated_port     = rule.value.translated_port
        }
      }
    }
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_firewall.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_metric_categories

    content {
      category = metric.value
      enabled  = true
    }
  }
}
