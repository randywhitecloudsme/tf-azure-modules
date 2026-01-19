variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-vnet-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "example-vnet"
}

variable "address_space" {
  description = "The address space for the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnets" {
  description = "Map of subnets to create"
  type = map(object({
    name             = string
    address_prefixes = list(string)
    delegation = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = optional(list(string))
      })
    }))
  }))
  default = {
    subnet1 = {
      name             = "subnet-1"
      address_prefixes = ["10.0.1.0/24"]
    }
    subnet2 = {
      name             = "subnet-2"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}

variable "network_security_groups" {
  description = "Map of network security groups to create"
  type = map(object({
    name = string
    security_rules = optional(list(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = optional(string)
      destination_port_range     = optional(string)
      source_address_prefix      = optional(string)
      destination_address_prefix = optional(string)
    })), [])
  }))
  default = {
    nsg1 = {
      name = "nsg-1"
      security_rules = [
        {
          name                       = "AllowSSH"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }
}

variable "subnet_nsg_associations" {
  description = "Map of subnet to NSG associations"
  type = map(object({
    subnet_key = string
    nsg_key    = string
  }))
  default = {
    assoc1 = {
      subnet_key = "subnet1"
      nsg_key    = "nsg1"
    }
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
