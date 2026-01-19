variable "name" {
  description = "The name of the network security group (2-80 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "NSG name must be 2-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the NSG will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the NSG"
  type        = map(string)
  default     = {}
}

variable "security_rules" {
  description = "Map of security rules to create"
  type = map(object({
    name                                       = string
    priority                                   = number
    direction                                  = string
    access                                     = string
    protocol                                   = string
    source_port_range                          = optional(string)
    source_port_ranges                         = optional(list(string))
    destination_port_range                     = optional(string)
    destination_port_ranges                    = optional(list(string))
    source_address_prefix                      = optional(string)
    source_address_prefixes                    = optional(list(string))
    destination_address_prefix                 = optional(string)
    destination_address_prefixes               = optional(list(string))
    description                                = optional(string)
    source_application_security_group_ids      = optional(list(string))
    destination_application_security_group_ids = optional(list(string))
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in var.security_rules : (
        rule.priority >= 100 && rule.priority <= 4096
      )
    ])
    error_message = "Security rule priority must be between 100 and 4096."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : (
        contains(["Inbound", "Outbound"], rule.direction)
      )
    ])
    error_message = "Direction must be either 'Inbound' or 'Outbound'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : (
        contains(["Allow", "Deny"], rule.access)
      )
    ])
    error_message = "Access must be either 'Allow' or 'Deny'."
  }

  validation {
    condition = alltrue([
      for rule in var.security_rules : (
        contains(["Tcp", "Udp", "Icmp", "Esp", "Ah", "*"], rule.protocol)
      )
    ])
    error_message = "Protocol must be one of: Tcp, Udp, Icmp, Esp, Ah, or *."
  }
}

variable "subnet_associations" {
  description = "Map of subnet IDs to associate with this NSG"
  type        = map(string)
  default     = {}
}

variable "network_interface_associations" {
  description = "Map of network interface IDs to associate with this NSG"
  type        = map(string)
  default     = {}
}

# Flow Logs Configuration
variable "enable_flow_logs" {
  description = "Enable NSG flow logs"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher (required if flow logs are enabled)"
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher (required if flow logs are enabled)"
  type        = string
  default     = null
}

variable "flow_log_storage_account_id" {
  description = "Storage account ID for flow logs (required if flow logs are enabled)"
  type        = string
  default     = null
}

variable "flow_log_version" {
  description = "Version of the flow log (1 or 2)"
  type        = number
  default     = 2

  validation {
    condition     = contains([1, 2], var.flow_log_version)
    error_message = "Flow log version must be either 1 or 2."
  }
}

variable "flow_log_retention_enabled" {
  description = "Enable retention policy for flow logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs (0 means indefinitely)"
  type        = number
  default     = 90

  validation {
    condition     = var.flow_log_retention_days >= 0 && var.flow_log_retention_days <= 365
    error_message = "Retention days must be between 0 and 365."
  }
}

# Traffic Analytics Configuration
variable "enable_traffic_analytics" {
  description = "Enable traffic analytics (requires flow logs to be enabled)"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for traffic analytics and diagnostics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_location" {
  description = "Log Analytics workspace location for traffic analytics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  description = "Log Analytics workspace resource ID for traffic analytics"
  type        = string
  default     = null
}

variable "traffic_analytics_interval" {
  description = "Traffic analytics processing interval in minutes (10 or 60)"
  type        = number
  default     = 60

  validation {
    condition     = contains([10, 60], var.traffic_analytics_interval)
    error_message = "Traffic analytics interval must be either 10 or 60 minutes."
  }
}

# Diagnostic Settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the NSG"
  type        = bool
  default     = false
}

variable "diagnostic_log_categories" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default     = ["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"]

  validation {
    condition = alltrue([
      for category in var.diagnostic_log_categories : (
        contains(["NetworkSecurityGroupEvent", "NetworkSecurityGroupRuleCounter"], category)
      )
    ])
    error_message = "Valid log categories are: NetworkSecurityGroupEvent, NetworkSecurityGroupRuleCounter."
  }
}
