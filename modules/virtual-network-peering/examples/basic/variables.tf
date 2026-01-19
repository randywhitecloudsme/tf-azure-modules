variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "hub_resource_group_name" {
  description = "The name of the resource group for hub VNet"
  type        = string
  default     = "rg-hub-peering-example"
}

variable "hub_vnet_name" {
  description = "The name of the hub virtual network"
  type        = string
  default     = "vnet-hub-example"
}

variable "hub_address_space" {
  description = "The address space of the hub virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_resource_group_name" {
  description = "The name of the resource group for spoke VNet"
  type        = string
  default     = "rg-spoke-peering-example"
}

variable "spoke_vnet_name" {
  description = "The name of the spoke virtual network"
  type        = string
  default     = "vnet-spoke-example"
}

variable "spoke_address_space" {
  description = "The address space of the spoke virtual network"
  type        = list(string)
  default     = ["10.1.0.0/16"]
}
