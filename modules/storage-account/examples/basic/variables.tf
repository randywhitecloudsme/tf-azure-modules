variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-storage-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "The name of the storage account"
  type        = string
  default     = "examplestorageacct123"
}

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "Storage account replication type"
  type        = string
  default     = "LRS"
}

variable "blob_properties" {
  description = "Blob properties configuration"
  type = object({
    versioning_enabled = optional(bool, false)
    delete_retention_policy = optional(object({
      days = number
    }))
    container_delete_retention_policy = optional(object({
      days = number
    }))
  })
  default = {
    versioning_enabled = true
    delete_retention_policy = {
      days = 7
    }
  }
}

variable "containers" {
  description = "Map of storage containers to create"
  type = map(object({
    name                  = string
    container_access_type = optional(string, "private")
  }))
  default = {
    data = {
      name                  = "data"
      container_access_type = "private"
    }
    backup = {
      name                  = "backup"
      container_access_type = "private"
    }
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
