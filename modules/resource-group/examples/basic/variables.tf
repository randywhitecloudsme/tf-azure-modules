variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
