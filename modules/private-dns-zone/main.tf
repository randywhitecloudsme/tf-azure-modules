# Private DNS Zone
resource "azurerm_private_dns_zone" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "soa_record" {
    for_each = var.soa_record != null ? [var.soa_record] : []

    content {
      email        = soa_record.value.email
      expire_time  = lookup(soa_record.value, "expire_time", 2419200)
      minimum_ttl  = lookup(soa_record.value, "minimum_ttl", 10)
      refresh_time = lookup(soa_record.value, "refresh_time", 3600)
      retry_time   = lookup(soa_record.value, "retry_time", 300)
      ttl          = lookup(soa_record.value, "ttl", 3600)
    }
  }

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Virtual Network Links
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = var.virtual_network_links

  name                  = each.value.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = each.value.virtual_network_id
  registration_enabled  = lookup(each.value, "registration_enabled", false)
  tags                  = var.tags
}

# A Records
resource "azurerm_private_dns_a_record" "this" {
  for_each = var.a_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

# AAAA Records
resource "azurerm_private_dns_aaaa_record" "this" {
  for_each = var.aaaa_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

# CNAME Records
resource "azurerm_private_dns_cname_record" "this" {
  for_each = var.cname_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  record              = each.value.record
  tags                = var.tags
}

# MX Records
resource "azurerm_private_dns_mx_record" "this" {
  for_each = var.mx_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records

    content {
      preference = record.value.preference
      exchange   = record.value.exchange
    }
  }
}

# PTR Records
resource "azurerm_private_dns_ptr_record" "this" {
  for_each = var.ptr_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  records             = each.value.records
  tags                = var.tags
}

# SRV Records
resource "azurerm_private_dns_srv_record" "this" {
  for_each = var.srv_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records

    content {
      priority = record.value.priority
      weight   = record.value.weight
      port     = record.value.port
      target   = record.value.target
    }
  }
}

# TXT Records
resource "azurerm_private_dns_txt_record" "this" {
  for_each = var.txt_records

  name                = each.value.name
  zone_name           = azurerm_private_dns_zone.this.name
  resource_group_name = var.resource_group_name
  ttl                 = each.value.ttl
  tags                = var.tags

  dynamic "record" {
    for_each = each.value.records

    content {
      value = record.value
    }
  }
}
