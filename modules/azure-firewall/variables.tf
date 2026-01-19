variable "name" {
  description = "The name of the Azure Firewall (1-56 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,54}[a-zA-Z0-9_]$", var.name))
    error_message = "Firewall name must be 1-56 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the firewall will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the firewall"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The ID of the AzureFirewallSubnet"
  type        = string
}

# SKU Configuration
variable "sku_name" {
  description = "SKU name of the Firewall"
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_VNet", "AZFW_Hub"], var.sku_name)
    error_message = "SKU name must be either 'AZFW_VNet' or 'AZFW_Hub'."
  }
}

variable "sku_tier" {
  description = "SKU tier of the Firewall"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium", "Basic"], var.sku_tier)
    error_message = "SKU tier must be one of: Standard, Premium, Basic."
  }
}

variable "availability_zones" {
  description = "Availability zones for the firewall"
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Public IP Configuration
variable "create_public_ip" {
  description = "Create a new public IP for the firewall"
  type        = bool
  default     = true
}

variable "public_ip_address_id" {
  description = "ID of an existing public IP (if not creating a new one)"
  type        = string
  default     = null
}

# Management IP Configuration (for forced tunneling)
variable "management_ip_configuration" {
  description = "Management IP configuration for forced tunneling"
  type = object({
    name                 = string
    subnet_id            = string
    public_ip_address_id = string
  })
  default = null
}

# Virtual Hub Configuration (for Virtual WAN)
variable "virtual_hub" {
  description = "Virtual Hub configuration for Virtual WAN"
  type = object({
    virtual_hub_id  = string
    public_ip_count = optional(number)
  })
  default = null
}

# Firewall Policy
variable "create_firewall_policy" {
  description = "Create a new firewall policy"
  type        = bool
  default     = true
}

variable "firewall_policy_id" {
  description = "ID of an existing firewall policy (if not creating a new one)"
  type        = string
  default     = null
}

# DNS Configuration
variable "dns_servers" {
  description = "List of custom DNS servers for the firewall"
  type        = list(string)
  default     = []
}

variable "dns_proxy_enabled" {
  description = "Enable DNS proxy"
  type        = bool
  default     = true
}

# Threat Intelligence
variable "threat_intel_mode" {
  description = "Threat intelligence mode"
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "Threat intelligence mode must be one of: Off, Alert, Deny."
  }
}

variable "threat_intelligence_allowlist" {
  description = "Threat intelligence allowlist"
  type = object({
    ip_addresses = optional(list(string))
    fqdns        = optional(list(string))
  })
  default = null
}

# SNAT Configuration
variable "private_ip_ranges" {
  description = "List of private IP ranges to which traffic won't be SNAT'ed"
  type        = list(string)
  default     = []
}

# Intrusion Detection and Prevention System (IDPS)
variable "intrusion_detection" {
  description = "Intrusion detection configuration (Premium SKU only)"
  type = object({
    mode = string
    signature_overrides = optional(list(object({
      id    = string
      state = string
    })))
    traffic_bypass = optional(list(object({
      name                  = string
      protocol              = string
      description           = optional(string)
      destination_addresses = optional(list(string))
      destination_ports     = optional(list(string))
      source_addresses      = optional(list(string))
      source_ports          = optional(list(string))
    })))
  })
  default = null

  validation {
    condition = var.intrusion_detection == null || (
      contains(["Off", "Alert", "Deny"], var.intrusion_detection.mode)
    )
    error_message = "Intrusion detection mode must be one of: Off, Alert, Deny."
  }
}

# Rule Collection Groups
variable "rule_collection_groups" {
  description = "Map of firewall policy rule collection groups"
  type = map(object({
    name     = string
    priority = number
    application_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rules = list(object({
        name        = string
        description = optional(string)
        protocols = object({
          type = string
          port = number
        })
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_fqdn_tags = optional(list(string))
      }))
    })))
    network_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rules = list(object({
        name                  = string
        protocols             = list(string)
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_addresses = optional(list(string))
        destination_ip_groups = optional(list(string))
        destination_fqdns     = optional(list(string))
        destination_ports     = list(string)
      }))
    })))
    nat_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rules = list(object({
        name                = string
        protocols           = list(string)
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = string
        destination_ports   = list(string)
        translated_address  = optional(string)
        translated_fqdn     = optional(string)
        translated_port     = number
      }))
    })))
  }))
  default = {}

  validation {
    condition = alltrue([
      for group in var.rule_collection_groups : (
        group.priority >= 100 && group.priority <= 65000
      )
    ])
    error_message = "Rule collection group priority must be between 100 and 65000."
  }
}

# Diagnostic Settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the firewall"
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
    "AzureFirewallApplicationRule",
    "AzureFirewallNetworkRule",
    "AzureFirewallDnsProxy"
  ]
}

variable "diagnostic_metric_categories" {
  description = "List of diagnostic metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}
