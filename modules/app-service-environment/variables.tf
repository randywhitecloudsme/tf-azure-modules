variable "name" {
  description = "The name of the App Service Environment"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][-a-zA-Z0-9]{0,35}[a-zA-Z0-9]$", var.name))
    error_message = "ASE name must be between 1 and 37 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet for the App Service Environment (must be empty and /24 or larger)"
  type        = string
}

variable "internal_load_balancing_mode" {
  description = "Specifies which endpoints to serve internally (None, Web, Publishing, Web,Publishing)"
  type        = string
  default     = "Web, Publishing"

  validation {
    condition     = contains(["None", "Web", "Publishing", "Web, Publishing"], var.internal_load_balancing_mode)
    error_message = "Internal load balancing mode must be None, Web, Publishing, or 'Web, Publishing'."
  }
}

variable "zone_redundant" {
  description = "Enable zone redundancy for the App Service Environment (requires Premium SKU and supported regions)"
  type        = bool
  default     = false
}

variable "cluster_settings" {
  description = "List of cluster settings for the App Service Environment"
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "virtual_network_id" {
  description = "The ID of the virtual network (required for private DNS zone link)"
  type        = string
  default     = null
}

variable "create_private_dns_zone" {
  description = "Create and configure private DNS zone for internal ASE"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for monitoring"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "A maximum of 50 tags can be applied to each resource."
  }
}
