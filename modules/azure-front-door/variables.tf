variable "name" {
  description = "The name of the Front Door profile"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9-]{0,62}[a-zA-Z0-9]$", var.name))
    error_message = "Front Door name must be 2-64 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Front Door"
  type        = string
}

variable "sku_name" {
  description = "The SKU name of the Front Door (Standard_AzureFrontDoor or Premium_AzureFrontDoor)"
  type        = string
  default     = "Standard_AzureFrontDoor"

  validation {
    condition     = contains(["Standard_AzureFrontDoor", "Premium_AzureFrontDoor"], var.sku_name)
    error_message = "SKU must be either Standard_AzureFrontDoor or Premium_AzureFrontDoor."
  }
}

variable "endpoints" {
  description = "List of Front Door endpoints"
  type = list(object({
    name    = string
    enabled = optional(bool)
  }))

  validation {
    condition     = length(var.endpoints) > 0
    error_message = "At least one endpoint must be defined."
  }
}

variable "origin_groups" {
  description = "List of origin groups"
  type = list(object({
    name                            = string
    sample_size                     = optional(number)
    successful_samples_required     = optional(number)
    additional_latency_milliseconds = optional(number)
    health_probe_enabled            = optional(bool)
    health_probe_protocol           = optional(string)
    health_probe_interval           = optional(number)
    health_probe_path               = optional(string)
    health_probe_request_type       = optional(string)
    session_affinity_enabled        = optional(bool)
  }))

  validation {
    condition     = length(var.origin_groups) > 0
    error_message = "At least one origin group must be defined."
  }
}

variable "origins" {
  description = "List of origins"
  type = list(object({
    name                           = string
    origin_group_name              = string
    host_name                      = string
    enabled                        = optional(bool)
    http_port                      = optional(number)
    https_port                     = optional(number)
    origin_host_header             = optional(string)
    priority                       = optional(number)
    weight                         = optional(number)
    certificate_name_check_enabled = optional(bool)
    private_link_target_id         = optional(string)
    private_link_location          = optional(string)
    private_link_request_message   = optional(string)
    private_link_target_type       = optional(string)
  }))

  validation {
    condition     = length(var.origins) > 0
    error_message = "At least one origin must be defined."
  }
}

variable "routes" {
  description = "List of routes"
  type = list(object({
    name                          = string
    endpoint_name                 = string
    origin_group_name             = string
    origin_names                  = list(string)
    enabled                       = optional(bool)
    forwarding_protocol           = optional(string)
    https_redirect_enabled        = optional(bool)
    patterns_to_match             = optional(list(string))
    supported_protocols           = optional(list(string))
    custom_domain_names           = optional(list(string))
    link_to_default_domain        = optional(bool)
    cache_enabled                 = optional(bool)
    query_string_caching_behavior = optional(string)
    query_strings                 = optional(list(string))
    compression_enabled           = optional(bool)
    content_types_to_compress     = optional(list(string))
    rule_set_names                = optional(list(string))
  }))

  validation {
    condition     = length(var.routes) > 0
    error_message = "At least one route must be defined."
  }
}

variable "custom_domains" {
  description = "List of custom domains"
  type = list(object({
    name                = string
    host_name           = string
    certificate_type    = optional(string)
    minimum_tls_version = optional(string)
  }))
  default = []
}

variable "rule_set_names" {
  description = "List of rule set names to create"
  type        = list(string)
  default     = []
}

variable "waf_policy_id" {
  description = "The resource ID of the Front Door WAF policy to associate"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
