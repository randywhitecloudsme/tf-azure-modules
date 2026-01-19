variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-route-table-example"
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

variable "subnet_name" {
  description = "The name of the subnet"
  type        = string
  default     = "subnet-example"
}

variable "subnet_prefixes" {
  description = "The address prefixes of the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "route_table_name" {
  description = "The name of the route table"
  type        = string
  default     = "rt-example"
}
