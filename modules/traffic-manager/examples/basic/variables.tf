variable "location" {
  description = "The primary Azure region"
  type        = string
  default     = "eastus"
}

variable "secondary_location" {
  description = "The secondary Azure region"
  type        = string
  default     = "westus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "rg-traffic-manager-example"
}

variable "traffic_manager_name" {
  description = "The name of the Traffic Manager profile"
  type        = string
  default     = "tm-example"
}

variable "dns_relative_name" {
  description = "The DNS relative name for the Traffic Manager profile"
  type        = string
  default     = "tm-example-app"
}
