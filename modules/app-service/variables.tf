variable "service_plan_name" {
  description = "The name of the Service Plan"
  type        = string
}

variable "app_name" {
  description = "The name of the App Service"
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "os_type" {
  description = "The OS type for the Service Plan (Linux or Windows)"
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either 'Linux' or 'Windows'."
  }
}

variable "sku_name" {
  description = "The SKU for the Service Plan (e.g., B1, S1, P1v2)"
  type        = string
  default     = "B1"
}

variable "always_on" {
  description = "Should the app be loaded at all times?"
  type        = bool
  default     = true
}

variable "ftps_state" {
  description = "State of FTP / FTPS service (AllAllowed, FtpsOnly, Disabled)"
  type        = string
  default     = "FtpsOnly"
}

variable "http2_enabled" {
  description = "Should HTTP2 be enabled?"
  type        = bool
  default     = true
}

variable "minimum_tls_version" {
  description = "The minimum supported TLS version"
  type        = string
  default     = "1.2"
}

variable "application_stack" {
  description = "Application stack configuration"
  type        = map(string)
  default     = null
}

variable "app_settings" {
  description = "Map of app settings"
  type        = map(string)
  default     = {}
}

variable "connection_strings" {
  description = "List of connection strings"
  type = list(object({
    name  = string
    type  = string
    value = string
  }))
  default   = []
  sensitive = true
}

variable "https_only" {
  description = "Should the app service only be accessible via HTTPS?"
  type        = bool
  default     = true
}

variable "enable_system_assigned_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = false
}

variable "vnet_integration_enabled" {
  description = "Enable VNet integration"
  type        = bool
  default     = false
}

variable "vnet_integration_subnet_id" {
  description = "Subnet ID for VNet integration (required if vnet_integration_enabled is true)"
  type        = string
  default     = null
}

variable "health_check_path" {
  description = "Path to perform health checks on"
  type        = string
  default     = null
}

variable "health_check_eviction_time_in_min" {
  description = "Time in minutes after which unhealthy instances are removed"
  type        = number
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
