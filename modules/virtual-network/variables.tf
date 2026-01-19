variable "name" {
  description = "The name of the virtual network (2-64 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,62}[a-zA-Z0-9_]$", var.name))
    error_message = "VNet name must be 2-64 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the virtual network will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0
    error_message = "At least one address space must be specified."
  }
}

variable "dns_servers" {
  description = "List of DNS servers for the virtual network"
  type        = list(string)
  default     = []
}

variable "ddos_protection_plan_id" {
  description = "ID of the DDoS protection plan to associate with the VNet"
  type        = string
  default     = null
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    name                                          = string
    address_prefixes                              = list(string)
    service_endpoints                             = optional(list(string), [])
    private_endpoint_network_policies_enabled     = optional(bool, true)
    private_link_service_network_policies_enabled = optional(bool, true)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
  default = {}
}

variable "network_security_groups" {
  description = "Map of network security groups to create"
  type = map(object({
    name = string
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), [])
  }))
  default = {}
}

variable "subnet_nsg_associations" {
  description = "Map of subnet to NSG associations"
  type = map(object({
    subnet_key = string
    nsg_key    = string
  }))
  default = {}
}

variable "enable_flow_logs" {
  description = "Enable NSG flow logs"
  type        = bool
  default     = false
}

variable "network_watcher_name" {
  description = "Name of the Network Watcher (required if enable_flow_logs is true)"
  type        = string
  default     = null
}

variable "network_watcher_resource_group_name" {
  description = "Resource group name of the Network Watcher (required if enable_flow_logs is true)"
  type        = string
  default     = null
}

variable "flow_log_storage_account_id" {
  description = "Storage Account ID for flow logs (required if enable_flow_logs is true)"
  type        = string
  default     = null
}

variable "flow_log_retention_days" {
  description = "Number of days to retain flow logs"
  type        = number
  default     = 7

  validation {
    condition     = var.flow_log_retention_days >= 0 && var.flow_log_retention_days <= 365
    error_message = "Retention days must be between 0 and 365."
  }
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics and traffic analytics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  description = "Log Analytics Workspace Resource ID for traffic analytics"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
