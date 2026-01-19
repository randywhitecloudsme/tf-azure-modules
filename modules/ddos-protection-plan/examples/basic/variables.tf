variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-ddos-example"
}

variable "ddos_plan_name" {
  description = "The name of the DDoS Protection Plan"
  type        = string
  default     = "ddos-plan-example"
}

variable "vnet_name" {
  description = "The name of the virtual network"
  type        = string
  default     = "vnet-protected"
}

variable "address_space" {
  description = "The address space of the virtual network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefixes" {
  description = "The address prefixes of the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
