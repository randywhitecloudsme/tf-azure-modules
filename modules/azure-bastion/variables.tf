variable "name" {
  description = "The name of the Azure Bastion host"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Bastion name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the Bastion host will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the Bastion host"
  type        = string
}

variable "sku" {
  description = "The SKU of the Bastion host (Basic or Standard)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard"], var.sku)
    error_message = "SKU must be either Basic or Standard."
  }
}

variable "subnet_id" {
  description = "The ID of the AzureBastionSubnet (must be named exactly 'AzureBastionSubnet' with minimum /26 prefix)"
  type        = string
}

variable "create_public_ip" {
  description = "Whether to create a new public IP for Bastion"
  type        = bool
  default     = true
}

variable "public_ip_id" {
  description = "The ID of an existing public IP to use (required if create_public_ip is false)"
  type        = string
  default     = null
}

variable "public_ip_name" {
  description = "The name of the public IP (used only if create_public_ip is true)"
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

# Standard SKU Features
variable "copy_paste_enabled" {
  description = "Enable copy/paste feature (Standard SKU only)"
  type        = bool
  default     = true
}

variable "file_copy_enabled" {
  description = "Enable file copy feature (Standard SKU only, requires RDP)"
  type        = bool
  default     = false

  validation {
    condition     = var.file_copy_enabled == false || var.sku == "Standard"
    error_message = "file_copy_enabled requires Standard SKU."
  }
}

variable "ip_connect_enabled" {
  description = "Enable IP-based connection feature (Standard SKU only)"
  type        = bool
  default     = false

  validation {
    condition     = var.ip_connect_enabled == false || var.sku == "Standard"
    error_message = "ip_connect_enabled requires Standard SKU."
  }
}

variable "shareable_link_enabled" {
  description = "Enable shareable link feature (Standard SKU only)"
  type        = bool
  default     = false

  validation {
    condition     = var.shareable_link_enabled == false || var.sku == "Standard"
    error_message = "shareable_link_enabled requires Standard SKU."
  }
}

variable "tunneling_enabled" {
  description = "Enable native client tunneling (Standard SKU only)"
  type        = bool
  default     = false

  validation {
    condition     = var.tunneling_enabled == false || var.sku == "Standard"
    error_message = "tunneling_enabled requires Standard SKU."
  }
}

variable "scale_units" {
  description = "The number of scale units for Bastion (Standard SKU only, 2-50)"
  type        = number
  default     = 2

  validation {
    condition     = var.scale_units >= 2 && var.scale_units <= 50
    error_message = "scale_units must be between 2 and 50."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
