# Public IP for Load Balancer
resource "azurerm_public_ip" "this" {
  count = var.type == "public" ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = var.sku
  zones               = var.availability_zones
  tags                = var.tags
}

# Load Balancer
resource "azurerm_lb" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  sku_tier            = var.sku_tier
  tags                = var.tags

  dynamic "frontend_ip_configuration" {
    for_each = var.frontend_ip_configurations

    content {
      name                          = frontend_ip_configuration.value.name
      zones                         = lookup(frontend_ip_configuration.value, "zones", var.availability_zones)
      subnet_id                     = lookup(frontend_ip_configuration.value, "subnet_id", null)
      private_ip_address            = lookup(frontend_ip_configuration.value, "private_ip_address", null)
      private_ip_address_allocation = lookup(frontend_ip_configuration.value, "private_ip_address_allocation", "Dynamic")
      private_ip_address_version    = lookup(frontend_ip_configuration.value, "private_ip_address_version", "IPv4")
      public_ip_address_id          = var.type == "public" && frontend_ip_configuration.key == 0 ? azurerm_public_ip.this[0].id : lookup(frontend_ip_configuration.value, "public_ip_address_id", null)
      public_ip_prefix_id           = lookup(frontend_ip_configuration.value, "public_ip_prefix_id", null)
    }
  }

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Backend Address Pools
resource "azurerm_lb_backend_address_pool" "this" {
  for_each = var.backend_address_pools

  name            = each.value.name
  loadbalancer_id = azurerm_lb.this.id
}

# Backend Address Pool Addresses
resource "azurerm_lb_backend_address_pool_address" "this" {
  for_each = merge([
    for pool_key, pool in var.backend_address_pools : {
      for addr_key, addr in lookup(pool, "addresses", {}) :
      "${pool_key}-${addr_key}" => merge(addr, {
        backend_address_pool_id = azurerm_lb_backend_address_pool.this[pool_key].id
      })
    }
  ]...)

  name                    = each.value.name
  backend_address_pool_id = each.value.backend_address_pool_id
  virtual_network_id      = lookup(each.value, "virtual_network_id", null)
  ip_address              = lookup(each.value, "ip_address", null)
}

# Health Probes
resource "azurerm_lb_probe" "this" {
  for_each = var.health_probes

  name            = each.value.name
  loadbalancer_id = azurerm_lb.this.id
  protocol        = each.value.protocol
  port            = each.value.port
  request_path    = lookup(each.value, "request_path", null)
  interval_in_seconds = lookup(each.value, "interval_in_seconds", 15)
  number_of_probes    = lookup(each.value, "number_of_probes", 2)
  probe_threshold     = lookup(each.value, "probe_threshold", 1)
}

# Load Balancing Rules
resource "azurerm_lb_rule" "this" {
  for_each = var.load_balancing_rules

  name                           = each.value.name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = each.value.frontend_port
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_ids       = [for pool in each.value.backend_address_pool_names : azurerm_lb_backend_address_pool.this[pool].id]
  probe_id                       = lookup(each.value, "probe_name", null) != null ? azurerm_lb_probe.this[each.value.probe_name].id : null
  enable_floating_ip             = lookup(each.value, "enable_floating_ip", false)
  idle_timeout_in_minutes        = lookup(each.value, "idle_timeout_in_minutes", 4)
  load_distribution              = lookup(each.value, "load_distribution", "Default")
  disable_outbound_snat          = lookup(each.value, "disable_outbound_snat", false)
  enable_tcp_reset               = lookup(each.value, "enable_tcp_reset", false)
}

# Inbound NAT Rules
resource "azurerm_lb_nat_rule" "this" {
  for_each = var.inbound_nat_rules

  name                           = each.value.name
  resource_group_name            = var.resource_group_name
  loadbalancer_id                = azurerm_lb.this.id
  protocol                       = each.value.protocol
  frontend_port                  = lookup(each.value, "frontend_port", null)
  frontend_port_start            = lookup(each.value, "frontend_port_start", null)
  frontend_port_end              = lookup(each.value, "frontend_port_end", null)
  backend_port                   = each.value.backend_port
  frontend_ip_configuration_name = each.value.frontend_ip_configuration_name
  backend_address_pool_id        = lookup(each.value, "backend_address_pool_name", null) != null ? azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_name].id : null
  idle_timeout_in_minutes        = lookup(each.value, "idle_timeout_in_minutes", 4)
  enable_floating_ip             = lookup(each.value, "enable_floating_ip", false)
  enable_tcp_reset               = lookup(each.value, "enable_tcp_reset", false)
}

# Outbound Rules (for Standard SKU)
resource "azurerm_lb_outbound_rule" "this" {
  for_each = var.outbound_rules

  name                    = each.value.name
  loadbalancer_id         = azurerm_lb.this.id
  protocol                = each.value.protocol
  backend_address_pool_id = azurerm_lb_backend_address_pool.this[each.value.backend_address_pool_name].id
  allocated_outbound_ports = lookup(each.value, "allocated_outbound_ports", null)
  idle_timeout_in_minutes  = lookup(each.value, "idle_timeout_in_minutes", 4)
  enable_tcp_reset         = lookup(each.value, "enable_tcp_reset", false)

  dynamic "frontend_ip_configuration" {
    for_each = each.value.frontend_ip_configuration_names

    content {
      name = frontend_ip_configuration.value
    }
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_lb.this.id
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
