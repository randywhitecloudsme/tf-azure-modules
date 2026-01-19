variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-private-endpoint-example"
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
  description = "The name of the subnet for private endpoints"
  type        = string
  default     = "subnet-private-endpoints"
}

variable "subnet_prefixes" {
  description = "The address prefixes of the subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "storage_account_name" {
  description = "The name of the storage account (must be globally unique)"
  type        = string
  default     = "stpeexample12345"
}

variable "private_endpoint_name" {
  description = "The name of the private endpoint"
  type        = string
  default     = "pe-storage-blob"
}
