# Public IP for VPN Gateway
resource "azurerm_public_ip" "this" {
  count = var.public_ip_count

  name                = var.public_ip_count > 1 ? "${var.name}-pip-${count.index + 1}" : "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

# VPN Gateway
resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vpn"
  vpn_type            = var.vpn_type
  active_active       = var.active_active
  enable_bgp          = var.enable_bgp
  sku                 = var.sku
  generation          = var.generation
  tags                = var.tags

  ip_configuration {
    name                          = var.active_active ? "ip-config-1" : "ip-config"
    public_ip_address_id          = azurerm_public_ip.this[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.subnet_id
  }

  dynamic "ip_configuration" {
    for_each = var.active_active ? [1] : []

    content {
      name                          = "ip-config-2"
      public_ip_address_id          = azurerm_public_ip.this[1].id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.subnet_id
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = var.vpn_client_configuration != null ? [var.vpn_client_configuration] : []

    content {
      address_space         = vpn_client_configuration.value.address_space
      aad_tenant            = lookup(vpn_client_configuration.value, "aad_tenant", null)
      aad_audience          = lookup(vpn_client_configuration.value, "aad_audience", null)
      aad_issuer            = lookup(vpn_client_configuration.value, "aad_issuer", null)
      vpn_client_protocols  = lookup(vpn_client_configuration.value, "vpn_client_protocols", null)
      vpn_auth_types        = lookup(vpn_client_configuration.value, "vpn_auth_types", null)
      radius_server_address = lookup(vpn_client_configuration.value, "radius_server_address", null)
      radius_server_secret  = lookup(vpn_client_configuration.value, "radius_server_secret", null)

      dynamic "root_certificate" {
        for_each = lookup(vpn_client_configuration.value, "root_certificates", [])

        content {
          name             = root_certificate.value.name
          public_cert_data = root_certificate.value.public_cert_data
        }
      }

      dynamic "revoked_certificate" {
        for_each = lookup(vpn_client_configuration.value, "revoked_certificates", [])

        content {
          name       = revoked_certificate.value.name
          thumbprint = revoked_certificate.value.thumbprint
        }
      }
    }
  }

  dynamic "bgp_settings" {
    for_each = var.enable_bgp && var.bgp_settings != null ? [var.bgp_settings] : []

    content {
      asn         = lookup(bgp_settings.value, "asn", null)
      peer_weight = lookup(bgp_settings.value, "peer_weight", null)

      dynamic "peering_addresses" {
        for_each = lookup(bgp_settings.value, "peering_addresses", [])

        content {
          ip_configuration_name = peering_addresses.value.ip_configuration_name
          apipa_addresses       = lookup(peering_addresses.value, "apipa_addresses", null)
        }
      }
    }
  }

  dynamic "custom_route" {
    for_each = var.custom_route != null ? [var.custom_route] : []

    content {
      address_prefixes = custom_route.value.address_prefixes
    }
  }

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Local Network Gateways
resource "azurerm_local_network_gateway" "this" {
  for_each = var.local_network_gateways

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  gateway_address     = lookup(each.value, "gateway_address", null)
  gateway_fqdn        = lookup(each.value, "gateway_fqdn", null)
  address_space       = lookup(each.value, "address_space", [])
  tags                = var.tags

  dynamic "bgp_settings" {
    for_each = lookup(each.value, "bgp_settings", null) != null ? [each.value.bgp_settings] : []

    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = lookup(bgp_settings.value, "peer_weight", null)
    }
  }
}

# VPN Connections (Site-to-Site)
resource "azurerm_virtual_network_gateway_connection" "site_to_site" {
  for_each = var.site_to_site_connections

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "IPsec"

  virtual_network_gateway_id = azurerm_virtual_network_gateway.this.id
  local_network_gateway_id   = azurerm_local_network_gateway.this[each.value.local_network_gateway_key].id

  shared_key                       = each.value.shared_key
  connection_protocol              = lookup(each.value, "connection_protocol", "IKEv2")
  dpd_timeout_seconds              = lookup(each.value, "dpd_timeout_seconds", null)
  enable_bgp                       = lookup(each.value, "enable_bgp", false)
  local_azure_ip_address_enabled   = lookup(each.value, "local_azure_ip_address_enabled", false)
  peer_virtual_network_gateway_id  = lookup(each.value, "peer_virtual_network_gateway_id", null)
  use_policy_based_traffic_selectors = lookup(each.value, "use_policy_based_traffic_selectors", false)

  dynamic "ipsec_policy" {
    for_each = lookup(each.value, "ipsec_policy", null) != null ? [each.value.ipsec_policy] : []

    content {
      dh_group         = ipsec_policy.value.dh_group
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      pfs_group        = ipsec_policy.value.pfs_group
      sa_datasize      = lookup(ipsec_policy.value, "sa_datasize", null)
      sa_lifetime      = lookup(ipsec_policy.value, "sa_lifetime", null)
    }
  }

  dynamic "traffic_selector_policy" {
    for_each = lookup(each.value, "traffic_selector_policies", [])

    content {
      local_address_cidrs  = traffic_selector_policy.value.local_address_cidrs
      remote_address_cidrs = traffic_selector_policy.value.remote_address_cidrs
    }
  }

  tags = var.tags
}

# VPN Connections (VNet-to-VNet)
resource "azurerm_virtual_network_gateway_connection" "vnet_to_vnet" {
  for_each = var.vnet_to_vnet_connections

  name                = each.value.name
  location            = var.location
  resource_group_name = var.resource_group_name
  type                = "Vnet2Vnet"

  virtual_network_gateway_id      = azurerm_virtual_network_gateway.this.id
  peer_virtual_network_gateway_id = each.value.peer_virtual_network_gateway_id

  shared_key                  = each.value.shared_key
  connection_protocol         = lookup(each.value, "connection_protocol", "IKEv2")
  dpd_timeout_seconds         = lookup(each.value, "dpd_timeout_seconds", null)
  enable_bgp                  = lookup(each.value, "enable_bgp", false)
  local_azure_ip_address_enabled = lookup(each.value, "local_azure_ip_address_enabled", false)

  dynamic "ipsec_policy" {
    for_each = lookup(each.value, "ipsec_policy", null) != null ? [each.value.ipsec_policy] : []

    content {
      dh_group         = ipsec_policy.value.dh_group
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      pfs_group        = ipsec_policy.value.pfs_group
      sa_datasize      = lookup(ipsec_policy.value, "sa_datasize", null)
      sa_lifetime      = lookup(ipsec_policy.value, "sa_lifetime", null)
    }
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_virtual_network_gateway.this.id
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
