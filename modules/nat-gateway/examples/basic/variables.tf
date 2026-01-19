variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "subnet_associations" {
  description = "Map of subnet IDs to associate with NAT Gateway"
  type        = map(string)
  default     = {}
}
