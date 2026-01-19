variable "name" {
  description = "The name of the Traffic Manager profile"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "Traffic Manager name must be 2-63 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "traffic_routing_method" {
  description = "Traffic routing method (Performance, Priority, Weighted, Geographic, MultiValue, Subnet)"
  type        = string

  validation {
    condition     = contains(["Performance", "Priority", "Weighted", "Geographic", "MultiValue", "Subnet"], var.traffic_routing_method)
    error_message = "Routing method must be Performance, Priority, Weighted, Geographic, MultiValue, or Subnet."
  }
}

variable "dns_relative_name" {
  description = "The relative DNS name for the profile (results in <name>.trafficmanager.net)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,61}[a-zA-Z0-9]$", var.dns_relative_name))
    error_message = "DNS relative name must be 2-63 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "dns_ttl" {
  description = "The DNS TTL in seconds (30-999999)"
  type        = number
  default     = 60

  validation {
    condition     = var.dns_ttl >= 30 && var.dns_ttl <= 999999
    error_message = "DNS TTL must be between 30 and 999999 seconds."
  }
}

variable "monitor_protocol" {
  description = "The protocol for endpoint health checks (HTTP, HTTPS, TCP)"
  type        = string
  default     = "HTTPS"

  validation {
    condition     = contains(["HTTP", "HTTPS", "TCP"], var.monitor_protocol)
    error_message = "Monitor protocol must be HTTP, HTTPS, or TCP."
  }
}

variable "monitor_port" {
  description = "The port for endpoint health checks"
  type        = number
  default     = 443

  validation {
    condition     = var.monitor_port >= 1 && var.monitor_port <= 65535
    error_message = "Monitor port must be between 1 and 65535."
  }
}

variable "monitor_path" {
  description = "The path for HTTP/HTTPS health checks"
  type        = string
  default     = "/"
}

variable "monitor_interval" {
  description = "The interval between health checks in seconds (10 or 30)"
  type        = number
  default     = 30

  validation {
    condition     = contains([10, 30], var.monitor_interval)
    error_message = "Monitor interval must be 10 or 30 seconds."
  }
}

variable "monitor_timeout" {
  description = "The timeout for health checks in seconds (5-10)"
  type        = number
  default     = 10

  validation {
    condition     = var.monitor_timeout >= 5 && var.monitor_timeout <= 10
    error_message = "Monitor timeout must be between 5 and 10 seconds."
  }
}

variable "monitor_tolerated_failures" {
  description = "The number of tolerated failures before marking endpoint unhealthy (0-9)"
  type        = number
  default     = 3

  validation {
    condition     = var.monitor_tolerated_failures >= 0 && var.monitor_tolerated_failures <= 9
    error_message = "Tolerated failures must be between 0 and 9."
  }
}

variable "monitor_custom_headers" {
  description = "List of custom headers for health checks"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "monitor_expected_status_code_ranges" {
  description = "List of expected HTTP status code ranges (e.g., ['200-202', '301-302'])"
  type        = list(string)
  default     = null
}

variable "traffic_view_enabled" {
  description = "Enable Traffic View for analytics"
  type        = bool
  default     = false
}

variable "max_return" {
  description = "Maximum number of endpoints to return (for MultiValue routing)"
  type        = number
  default     = null

  validation {
    condition     = var.max_return == null || (var.max_return >= 1 && var.max_return <= 8)
    error_message = "max_return must be between 1 and 8."
  }
}

variable "azure_endpoints" {
  description = "List of Azure endpoints"
  type = list(object({
    name               = string
    target_resource_id = string
    weight             = optional(number)
    priority           = optional(number)
    enabled            = optional(bool)
    geo_mappings       = optional(list(string))
    custom_headers     = optional(list(object({
      name  = string
      value = string
    })))
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })))
  }))
  default = []
}

variable "external_endpoints" {
  description = "List of external endpoints"
  type = list(object({
    name           = string
    target         = string
    weight         = optional(number)
    priority       = optional(number)
    enabled        = optional(bool)
    geo_mappings   = optional(list(string))
    custom_headers = optional(list(object({
      name  = string
      value = string
    })))
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })))
  }))
  default = []
}

variable "nested_endpoints" {
  description = "List of nested Traffic Manager endpoints"
  type = list(object({
    name                    = string
    target_resource_id      = string
    minimum_child_endpoints = number
    weight                  = optional(number)
    priority                = optional(number)
    enabled                 = optional(bool)
    geo_mappings            = optional(list(string))
    custom_headers          = optional(list(object({
      name  = string
      value = string
    })))
    subnets = optional(list(object({
      first = string
      last  = optional(string)
      scope = optional(number)
    })))
  }))
  default = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
