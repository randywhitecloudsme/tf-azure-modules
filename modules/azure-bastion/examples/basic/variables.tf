variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-bastion-example"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-example"
}

variable "address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "bastion_subnet_prefixes" {
  description = "The address prefixes of the AzureBastionSubnet (minimum /26)"
  type        = list(string)
  default     = ["10.0.254.0/26"]
}

variable "bastion_name" {
  description = "The name of the Azure Bastion host"
  type        = string
  default     = "bastion-example"
}
