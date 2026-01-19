variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-public-ip-example"
}

variable "public_ip_name" {
  description = "The name of the public IP"
  type        = string
  default     = "pip-example"
}

variable "domain_name_label" {
  description = "The DNS label for the public IP"
  type        = string
  default     = "pip-example-app"
}
