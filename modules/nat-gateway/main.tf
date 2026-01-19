# Public IP for NAT Gateway
resource "azurerm_public_ip" "this" {
  count = var.public_ip_count

  name                = var.public_ip_count > 1 ? "${var.name}-pip-${count.index + 1}" : "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

# Public IP Prefix (optional)
resource "azurerm_public_ip_prefix" "this" {
  count = var.create_public_ip_prefix ? 1 : 0

  name                = "${var.name}-pip-prefix"
  location            = var.location
  resource_group_name = var.resource_group_name
  prefix_length       = var.public_ip_prefix_length
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

# NAT Gateway
resource "azurerm_nat_gateway" "this" {
  name                    = var.name
  location                = var.location
  resource_group_name     = var.resource_group_name
  sku_name                = var.sku_name
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.availability_zones
  tags                    = var.tags

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Associate Public IPs with NAT Gateway
resource "azurerm_nat_gateway_public_ip_association" "this" {
  count = var.public_ip_count

  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = azurerm_public_ip.this[count.index].id
}

# Associate Public IP Prefix with NAT Gateway
resource "azurerm_nat_gateway_public_ip_prefix_association" "this" {
  count = var.create_public_ip_prefix ? 1 : 0

  nat_gateway_id      = azurerm_nat_gateway.this.id
  public_ip_prefix_id = azurerm_public_ip_prefix.this[0].id
}

# Associate Subnets with NAT Gateway
resource "azurerm_subnet_nat_gateway_association" "this" {
  for_each = var.subnet_associations

  subnet_id      = each.value
  nat_gateway_id = azurerm_nat_gateway.this.id
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_nat_gateway.this.id
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
