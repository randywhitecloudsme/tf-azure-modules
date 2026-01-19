variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-acr-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "acr_name" {
  description = "The name of the Container Registry"
  type        = string
  default     = "exampleacr12345"
}

variable "sku" {
  description = "The SKU for the Container Registry"
  type        = string
  default     = "Standard"
}

variable "admin_enabled" {
  description = "Whether to enable admin user"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
