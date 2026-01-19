variable "name" {
  description = "The name of the private endpoint"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Private endpoint name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the private endpoint will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the private endpoint"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the private endpoint will be created"
  type        = string
}

variable "private_connection_resource_id" {
  description = "The resource ID of the service to create a private endpoint for"
  type        = string
}

variable "is_manual_connection" {
  description = "Whether the connection requires manual approval from the service owner"
  type        = bool
  default     = false
}

variable "subresource_names" {
  description = "List of subresource names for the private endpoint (e.g., ['blob'], ['sqlServer'])"
  type        = list(string)
  default     = null

  validation {
    condition     = var.subresource_names == null || length(var.subresource_names) > 0
    error_message = "subresource_names must contain at least one subresource if specified."
  }
}

variable "request_message" {
  description = "A message to send to the service owner when is_manual_connection is true"
  type        = string
  default     = "Please approve this private endpoint connection"

  validation {
    condition     = length(var.request_message) <= 140
    error_message = "request_message must be 140 characters or less."
  }
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for DNS integration"
  type        = list(string)
  default     = null
}

variable "private_dns_zone_group_name" {
  description = "The name of the private DNS zone group"
  type        = string
  default     = null
}

variable "ip_configurations" {
  description = "List of custom IP configurations for the private endpoint"
  type = list(object({
    name               = string
    private_ip_address = string
    subresource_name   = optional(string)
    member_name        = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.ip_configurations : can(regex("^((25[0-5]|(2[0-4]|1\\d|[1-9]|)\\d)\\.?\\b){4}$", config.private_ip_address))
    ])
    error_message = "private_ip_address must be a valid IPv4 address."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
