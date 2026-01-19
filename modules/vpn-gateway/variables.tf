variable "name" {
  description = "The name of the VPN Gateway (1-80 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "VPN Gateway name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the VPN Gateway will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the VPN Gateway"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The ID of the GatewaySubnet"
  type        = string
}

# SKU Configuration
variable "sku" {
  description = "The SKU of the VPN Gateway"
  type        = string
  default     = "VpnGw1"

  validation {
    condition = contains([
      "Basic", "VpnGw1", "VpnGw2", "VpnGw3", "VpnGw4", "VpnGw5",
      "VpnGw1AZ", "VpnGw2AZ", "VpnGw3AZ", "VpnGw4AZ", "VpnGw5AZ"
    ], var.sku)
    error_message = "Invalid VPN Gateway SKU."
  }
}

variable "generation" {
  description = "The generation of the VPN Gateway (Generation1 or Generation2)"
  type        = string
  default     = "Generation1"

  validation {
    condition     = contains(["Generation1", "Generation2"], var.generation)
    error_message = "Generation must be either 'Generation1' or 'Generation2'."
  }
}

variable "vpn_type" {
  description = "The VPN type (RouteBased or PolicyBased)"
  type        = string
  default     = "RouteBased"

  validation {
    condition     = contains(["RouteBased", "PolicyBased"], var.vpn_type)
    error_message = "VPN type must be either 'RouteBased' or 'PolicyBased'."
  }
}

variable "active_active" {
  description = "Enable active-active mode"
  type        = bool
  default     = false
}

variable "public_ip_count" {
  description = "Number of public IPs (1 for active-passive, 2 for active-active)"
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 1 && var.public_ip_count <= 2
    error_message = "Public IP count must be 1 or 2."
  }
}

variable "availability_zones" {
  description = "Availability zones for zone-redundant SKUs"
  type        = list(string)
  default     = null
}

# BGP Configuration
variable "enable_bgp" {
  description = "Enable BGP"
  type        = bool
  default     = false
}

variable "bgp_settings" {
  description = "BGP settings for the VPN Gateway"
  type = object({
    asn         = optional(number)
    peer_weight = optional(number)
    peering_addresses = optional(list(object({
      ip_configuration_name = string
      apipa_addresses       = optional(list(string))
    })))
  })
  default = null

  validation {
    condition = var.bgp_settings == null || (
      var.bgp_settings.asn == null || (var.bgp_settings.asn >= 1 && var.bgp_settings.asn <= 4294967295)
    )
    error_message = "BGP ASN must be between 1 and 4294967295."
  }
}

# Point-to-Site VPN Configuration
variable "vpn_client_configuration" {
  description = "Point-to-Site VPN client configuration"
  type = object({
    address_space         = list(string)
    aad_tenant            = optional(string)
    aad_audience          = optional(string)
    aad_issuer            = optional(string)
    vpn_client_protocols  = optional(list(string))
    vpn_auth_types        = optional(list(string))
    radius_server_address = optional(string)
    radius_server_secret  = optional(string)
    root_certificates = optional(list(object({
      name             = string
      public_cert_data = string
    })))
    revoked_certificates = optional(list(object({
      name       = string
      thumbprint = string
    })))
  })
  default   = null
  sensitive = true
}

# Custom Routes
variable "custom_route" {
  description = "Custom routes for Point-to-Site VPN"
  type = object({
    address_prefixes = list(string)
  })
  default = null
}

# Local Network Gateways
variable "local_network_gateways" {
  description = "Map of local network gateways for Site-to-Site connections"
  type = map(object({
    name            = string
    gateway_address = optional(string)
    gateway_fqdn    = optional(string)
    address_space   = optional(list(string))
    bgp_settings = optional(object({
      asn                 = number
      bgp_peering_address = string
      peer_weight         = optional(number)
    }))
  }))
  default = {}
}

# Site-to-Site Connections
variable "site_to_site_connections" {
  description = "Map of Site-to-Site VPN connections"
  type = map(object({
    name                        = string
    local_network_gateway_key   = string
    shared_key                  = string
    connection_protocol         = optional(string)
    dpd_timeout_seconds         = optional(number)
    enable_bgp                  = optional(bool)
    local_azure_ip_address_enabled = optional(bool)
    use_policy_based_traffic_selectors = optional(bool)
    ipsec_policy = optional(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_datasize      = optional(number)
      sa_lifetime      = optional(number)
    }))
    traffic_selector_policies = optional(list(object({
      local_address_cidrs  = list(string)
      remote_address_cidrs = list(string)
    })))
  }))
  default   = {}
  sensitive = true

  validation {
    condition = alltrue([
      for conn in var.site_to_site_connections : (
        conn.connection_protocol == null || contains(["IKEv2", "IKEv1"], conn.connection_protocol)
      )
    ])
    error_message = "Connection protocol must be either 'IKEv2' or 'IKEv1'."
  }
}

# VNet-to-VNet Connections
variable "vnet_to_vnet_connections" {
  description = "Map of VNet-to-VNet connections"
  type = map(object({
    name                            = string
    peer_virtual_network_gateway_id = string
    shared_key                      = string
    connection_protocol             = optional(string)
    dpd_timeout_seconds             = optional(number)
    enable_bgp                      = optional(bool)
    local_azure_ip_address_enabled  = optional(bool)
    ipsec_policy = optional(object({
      dh_group         = string
      ike_encryption   = string
      ike_integrity    = string
      ipsec_encryption = string
      ipsec_integrity  = string
      pfs_group        = string
      sa_datasize      = optional(number)
      sa_lifetime      = optional(number)
    }))
  }))
  default   = {}
  sensitive = true
}

# Diagnostic Settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the VPN Gateway"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default = [
    "GatewayDiagnosticLog",
    "TunnelDiagnosticLog",
    "RouteDiagnosticLog",
    "IKEDiagnosticLog"
  ]
}

variable "diagnostic_metric_categories" {
  description = "List of diagnostic metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}
