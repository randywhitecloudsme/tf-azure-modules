variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-keyvault-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "key_vault_name" {
  description = "The name of the key vault"
  type        = string
  default     = "examplekv12345"
}

variable "secrets" {
  description = "Map of secrets to create"
  type = map(object({
    name         = string
    value        = string
    content_type = optional(string)
    tags         = optional(map(string))
  }))
  default = {
    example_secret = {
      name  = "example-secret"
      value = "example-value-123"
    }
  }
  sensitive = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
