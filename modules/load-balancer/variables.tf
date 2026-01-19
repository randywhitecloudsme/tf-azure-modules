variable "name" {
  description = "The name of the load balancer (1-80 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Load balancer name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the load balancer will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the load balancer"
  type        = map(string)
  default     = {}
}

variable "type" {
  description = "Type of load balancer: 'public' or 'private'"
  type        = string
  default     = "public"

  validation {
    condition     = contains(["public", "private"], var.type)
    error_message = "Type must be either 'public' or 'private'."
  }
}

variable "sku" {
  description = "The SKU of the load balancer"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Gateway"], var.sku)
    error_message = "SKU must be one of: Basic, Standard, Gateway."
  }
}

variable "sku_tier" {
  description = "The SKU tier of the load balancer"
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "SKU tier must be either 'Regional' or 'Global'."
  }
}

variable "availability_zones" {
  description = "Availability zones for the load balancer"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "frontend_ip_configurations" {
  description = "List of frontend IP configurations"
  type = list(object({
    name                          = string
    zones                         = optional(list(string))
    subnet_id                     = optional(string)
    private_ip_address            = optional(string)
    private_ip_address_allocation = optional(string)
    private_ip_address_version    = optional(string)
    public_ip_address_id          = optional(string)
    public_ip_prefix_id           = optional(string)
  }))
  default = [
    {
      name = "frontend-ip-config"
    }
  ]
}

variable "backend_address_pools" {
  description = "Map of backend address pools"
  type = map(object({
    name = string
    addresses = optional(map(object({
      name               = string
      virtual_network_id = optional(string)
      ip_address         = optional(string)
    })))
  }))
}

variable "health_probes" {
  description = "Map of health probes"
  type = map(object({
    name                = string
    protocol            = string
    port                = number
    request_path        = optional(string)
    interval_in_seconds = optional(number)
    number_of_probes    = optional(number)
    probe_threshold     = optional(number)
  }))
  default = {}

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        contains(["Tcp", "Http", "Https"], probe.protocol)
      )
    ])
    error_message = "Probe protocol must be one of: Tcp, Http, Https."
  }

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        probe.interval_in_seconds == null || (probe.interval_in_seconds >= 5 && probe.interval_in_seconds <= 2147483646)
      )
    ])
    error_message = "Probe interval must be between 5 and 2147483646 seconds."
  }

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        probe.number_of_probes == null || (probe.number_of_probes >= 1 && probe.number_of_probes <= 2147483647)
      )
    ])
    error_message = "Number of probes must be between 1 and 2147483647."
  }
}

variable "load_balancing_rules" {
  description = "Map of load balancing rules"
  type = map(object({
    name                           = string
    protocol                       = string
    frontend_port                  = number
    backend_port                   = number
    frontend_ip_configuration_name = string
    backend_address_pool_names     = list(string)
    probe_name                     = optional(string)
    enable_floating_ip             = optional(bool)
    idle_timeout_in_minutes        = optional(number)
    load_distribution              = optional(string)
    disable_outbound_snat          = optional(bool)
    enable_tcp_reset               = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in var.load_balancing_rules : (
        contains(["Tcp", "Udp", "All"], rule.protocol)
      )
    ])
    error_message = "Protocol must be one of: Tcp, Udp, All."
  }

  validation {
    condition = alltrue([
      for rule in var.load_balancing_rules : (
        rule.frontend_port >= 0 && rule.frontend_port <= 65535
      )
    ])
    error_message = "Frontend port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.load_balancing_rules : (
        rule.backend_port >= 0 && rule.backend_port <= 65535
      )
    ])
    error_message = "Backend port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for rule in var.load_balancing_rules : (
        rule.idle_timeout_in_minutes == null || (rule.idle_timeout_in_minutes >= 4 && rule.idle_timeout_in_minutes <= 30)
      )
    ])
    error_message = "Idle timeout must be between 4 and 30 minutes."
  }

  validation {
    condition = alltrue([
      for rule in var.load_balancing_rules : (
        rule.load_distribution == null || contains(["Default", "SourceIP", "SourceIPProtocol"], rule.load_distribution)
      )
    ])
    error_message = "Load distribution must be one of: Default, SourceIP, SourceIPProtocol."
  }
}

variable "inbound_nat_rules" {
  description = "Map of inbound NAT rules"
  type = map(object({
    name                           = string
    protocol                       = string
    frontend_port                  = optional(number)
    frontend_port_start            = optional(number)
    frontend_port_end              = optional(number)
    backend_port                   = number
    frontend_ip_configuration_name = string
    backend_address_pool_name      = optional(string)
    idle_timeout_in_minutes        = optional(number)
    enable_floating_ip             = optional(bool)
    enable_tcp_reset               = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in var.inbound_nat_rules : (
        contains(["Tcp", "Udp", "All"], rule.protocol)
      )
    ])
    error_message = "Protocol must be one of: Tcp, Udp, All."
  }
}

variable "outbound_rules" {
  description = "Map of outbound rules (Standard SKU only)"
  type = map(object({
    name                            = string
    protocol                        = string
    backend_address_pool_name       = string
    frontend_ip_configuration_names = list(string)
    allocated_outbound_ports        = optional(number)
    idle_timeout_in_minutes         = optional(number)
    enable_tcp_reset                = optional(bool)
  }))
  default = {}

  validation {
    condition = alltrue([
      for rule in var.outbound_rules : (
        contains(["Tcp", "Udp", "All"], rule.protocol)
      )
    ])
    error_message = "Protocol must be one of: Tcp, Udp, All."
  }
}

# Diagnostic Settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the load balancer"
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
  default     = ["LoadBalancerAlertEvent", "LoadBalancerProbeHealthStatus"]
}

variable "diagnostic_metric_categories" {
  description = "List of diagnostic metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}
