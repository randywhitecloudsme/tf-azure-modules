variable "location" {
  description = "The Azure region where resources will be created"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-frontdoor-example"
}

variable "front_door_name" {
  description = "The name of the Front Door profile"
  type        = string
  default     = "fd-example"
}

variable "origin_hostname" {
  description = "The hostname of the origin (e.g., your app service or website)"
  type        = string
  default     = "www.example.com"
}
