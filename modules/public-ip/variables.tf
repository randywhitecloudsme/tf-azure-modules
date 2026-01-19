variable "name" {
  description = "The name of the public IP"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Public IP name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the public IP will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the public IP"
  type        = string
}

variable "allocation_method" {
  description = "The allocation method for the public IP (Static or Dynamic)"
  type        = string
  default     = "Static"

  validation {
    condition     = contains(["Static", "Dynamic"], var.allocation_method)
    error_message = "allocation_method must be either Static or Dynamic."
  }
}

variable "sku" {
  description = "The SKU of the public IP (Basic or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be either Basic or Standard."
  }
}

variable "sku_tier" {
  description = "The SKU tier of the public IP (Regional or Global)"
  type        = string
  default     = "Regional"

  validation {
    condition     = contains(["Regional", "Global"], var.sku_tier)
    error_message = "sku_tier must be either Regional or Global."
  }
}

variable "ip_version" {
  description = "The IP version (IPv4 or IPv6)"
  type        = string
  default     = "IPv4"

  validation {
    condition     = contains(["IPv4", "IPv6"], var.ip_version)
    error_message = "ip_version must be either IPv4 or IPv6."
  }
}

variable "idle_timeout_in_minutes" {
  description = "The idle timeout in minutes (4-30)"
  type        = number
  default     = 4

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 30
    error_message = "idle_timeout_in_minutes must be between 4 and 30."
  }
}

variable "domain_name_label" {
  description = "The DNS label for the public IP (results in <label>.<location>.cloudapp.azure.com)"
  type        = string
  default     = null

  validation {
    condition     = var.domain_name_label == null || can(regex("^[a-z][a-z0-9-]{0,61}[a-z0-9]$", var.domain_name_label))
    error_message = "domain_name_label must be lowercase, 3-63 characters, start with letter, end with alphanumeric, and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "reverse_fqdn" {
  description = "The reverse FQDN for the public IP"
  type        = string
  default     = null
}

variable "public_ip_prefix_id" {
  description = "The ID of the public IP prefix to allocate from"
  type        = string
  default     = null
}

variable "zones" {
  description = "Availability zones for the public IP"
  type        = list(string)
  default     = null

  validation {
    condition = var.zones == null || alltrue([
      for zone in var.zones : contains(["1", "2", "3"], zone)
    ])
    error_message = "Zones must be a list containing '1', '2', and/or '3'."
  }
}

variable "edge_zone" {
  description = "The Edge Zone within the Azure region"
  type        = string
  default     = null
}

variable "ip_tags" {
  description = "A mapping of IP tags to assign to the public IP"
  type        = map(string)
  default     = null
}

variable "ddos_protection_mode" {
  description = "The DDoS protection mode (Disabled, Enabled, or VirtualNetworkInherited)"
  type        = string
  default     = "VirtualNetworkInherited"

  validation {
    condition     = contains(["Disabled", "Enabled", "VirtualNetworkInherited"], var.ddos_protection_mode)
    error_message = "ddos_protection_mode must be Disabled, Enabled, or VirtualNetworkInherited."
  }
}

variable "ddos_protection_plan_id" {
  description = "The ID of the DDoS Protection Plan (required if ddos_protection_mode is Enabled)"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
