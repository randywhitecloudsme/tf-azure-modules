variable "name" {
  description = "The name of the virtual network peering (source to destination)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Peering name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "reverse_name" {
  description = "The name of the reverse peering (destination to source)"
  type        = string
  default     = null

  validation {
    condition     = var.reverse_name == null || can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.reverse_name))
    error_message = "Peering name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

# Source VNet Configuration
variable "source_resource_group_name" {
  description = "The name of the resource group containing the source virtual network"
  type        = string
}

variable "source_virtual_network_name" {
  description = "The name of the source virtual network"
  type        = string
}

variable "source_virtual_network_id" {
  description = "The ID of the source virtual network (required for bidirectional peering)"
  type        = string
  default     = null
}

# Destination VNet Configuration
variable "destination_resource_group_name" {
  description = "The name of the resource group containing the destination virtual network"
  type        = string
  default     = null
}

variable "destination_virtual_network_name" {
  description = "The name of the destination virtual network (required for bidirectional peering)"
  type        = string
  default     = null
}

variable "destination_virtual_network_id" {
  description = "The ID of the destination (remote) virtual network"
  type        = string
}

# Peering Settings (Source to Destination)
variable "allow_virtual_network_access" {
  description = "Allow access from the source to the destination virtual network"
  type        = bool
  default     = true
}

variable "allow_forwarded_traffic" {
  description = "Allow traffic forwarded from other networks through the destination virtual network"
  type        = bool
  default     = false
}

variable "allow_gateway_transit" {
  description = "Allow the destination virtual network to use the source gateway"
  type        = bool
  default     = false
}

variable "use_remote_gateways" {
  description = "Use the destination virtual network's gateway"
  type        = bool
  default     = false
}

variable "triggers" {
  description = "A map of arbitrary keys and values that will force re-creation when changed"
  type        = map(string)
  default     = null
}

# Bidirectional Peering
variable "create_bidirectional_peering" {
  description = "Create bidirectional peering (both source->destination and destination->source)"
  type        = bool
  default     = true
}

# Reverse Peering Settings (Destination to Source)
variable "reverse_allow_virtual_network_access" {
  description = "Allow access from the destination to the source virtual network"
  type        = bool
  default     = true
}

variable "reverse_allow_forwarded_traffic" {
  description = "Allow traffic forwarded from other networks through the source virtual network"
  type        = bool
  default     = false
}

variable "reverse_allow_gateway_transit" {
  description = "Allow the source virtual network to use the destination gateway"
  type        = bool
  default     = false
}

variable "reverse_use_remote_gateways" {
  description = "Use the source virtual network's gateway"
  type        = bool
  default     = false
}

variable "reverse_triggers" {
  description = "A map of arbitrary keys and values for reverse peering that will force re-creation when changed"
  type        = map(string)
  default     = null
}
