resource "azurerm_traffic_manager_profile" "this" {
  name                   = var.name
  resource_group_name    = var.resource_group_name
  traffic_routing_method = var.traffic_routing_method

  dns_config {
    relative_name = var.dns_relative_name
    ttl           = var.dns_ttl
  }

  monitor_config {
    protocol                     = var.monitor_protocol
    port                         = var.monitor_port
    path                         = var.monitor_path
    interval_in_seconds          = var.monitor_interval
    timeout_in_seconds           = var.monitor_timeout
    tolerated_number_of_failures = var.monitor_tolerated_failures

    dynamic "custom_header" {
      for_each = var.monitor_custom_headers

      content {
        name  = custom_header.value.name
        value = custom_header.value.value
      }
    }

    expected_status_code_ranges = var.monitor_expected_status_code_ranges
  }

  traffic_view_enabled = var.traffic_view_enabled
  max_return           = var.max_return

  tags = var.tags
}

resource "azurerm_traffic_manager_azure_endpoint" "azure_endpoints" {
  for_each = { for ep in var.azure_endpoints : ep.name => ep }

  name               = each.value.name
  profile_id         = azurerm_traffic_manager_profile.this.id
  target_resource_id = each.value.target_resource_id
  weight             = lookup(each.value, "weight", null)
  priority           = lookup(each.value, "priority", null)
  enabled            = lookup(each.value, "enabled", true)
  geo_mappings       = lookup(each.value, "geo_mappings", null)

  dynamic "custom_header" {
    for_each = lookup(each.value, "custom_headers", [])

    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  dynamic "subnet" {
    for_each = lookup(each.value, "subnets", [])

    content {
      first = subnet.value.first
      last  = lookup(subnet.value, "last", null)
      scope = lookup(subnet.value, "scope", null)
    }
  }
}

resource "azurerm_traffic_manager_external_endpoint" "external_endpoints" {
  for_each = { for ep in var.external_endpoints : ep.name => ep }

  name         = each.value.name
  profile_id   = azurerm_traffic_manager_profile.this.id
  target       = each.value.target
  weight       = lookup(each.value, "weight", null)
  priority     = lookup(each.value, "priority", null)
  enabled      = lookup(each.value, "enabled", true)
  geo_mappings = lookup(each.value, "geo_mappings", null)

  dynamic "custom_header" {
    for_each = lookup(each.value, "custom_headers", [])

    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  dynamic "subnet" {
    for_each = lookup(each.value, "subnets", [])

    content {
      first = subnet.value.first
      last  = lookup(subnet.value, "last", null)
      scope = lookup(subnet.value, "scope", null)
    }
  }
}

resource "azurerm_traffic_manager_nested_endpoint" "nested_endpoints" {
  for_each = { for ep in var.nested_endpoints : ep.name => ep }

  name                    = each.value.name
  profile_id              = azurerm_traffic_manager_profile.this.id
  target_resource_id      = each.value.target_resource_id
  minimum_child_endpoints = each.value.minimum_child_endpoints
  weight                  = lookup(each.value, "weight", null)
  priority                = lookup(each.value, "priority", null)
  enabled                 = lookup(each.value, "enabled", true)
  geo_mappings            = lookup(each.value, "geo_mappings", null)

  dynamic "custom_header" {
    for_each = lookup(each.value, "custom_headers", [])

    content {
      name  = custom_header.value.name
      value = custom_header.value.value
    }
  }

  dynamic "subnet" {
    for_each = lookup(each.value, "subnets", [])

    content {
      first = subnet.value.first
      last  = lookup(subnet.value, "last", null)
      scope = lookup(subnet.value, "scope", null)
    }
  }
}
