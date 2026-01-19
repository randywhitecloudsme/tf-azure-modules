variable "name" {
  description = "The name of the route table"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Route table name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the route table will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the route table"
  type        = string
}

variable "disable_bgp_route_propagation" {
  description = "Disable propagation of routes learned by BGP on the route table"
  type        = bool
  default     = false
}

variable "routes" {
  description = "List of routes to create in the route table"
  type = list(object({
    name                   = string
    address_prefix         = string
    next_hop_type          = string
    next_hop_in_ip_address = optional(string)
  }))
  default = []

  validation {
    condition = alltrue([
      for route in var.routes : contains([
        "VirtualNetworkGateway",
        "VnetLocal",
        "Internet",
        "VirtualAppliance",
        "None"
      ], route.next_hop_type)
    ])
    error_message = "next_hop_type must be one of: VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance, or None."
  }

  validation {
    condition = alltrue([
      for route in var.routes :
      route.next_hop_type != "VirtualAppliance" || route.next_hop_in_ip_address != null
    ])
    error_message = "next_hop_in_ip_address is required when next_hop_type is VirtualAppliance."
  }

  validation {
    condition = alltrue([
      for route in var.routes :
      can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", route.name))
    ])
    error_message = "Route name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }

  validation {
    condition = alltrue([
      for route in var.routes :
      can(cidrhost(route.address_prefix, 0))
    ])
    error_message = "address_prefix must be a valid CIDR notation (e.g., 10.0.0.0/16)."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs to associate with this route table"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
