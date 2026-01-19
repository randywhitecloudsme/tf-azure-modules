variable "name" {
  description = "The name of the resource group (1-90 characters, alphanumerics, underscores, parentheses, hyphens, periods)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9_().-]{1,90}$", var.name))
    error_message = "Resource group name must be 1-90 characters and contain only alphanumerics, underscores, parentheses, hyphens, and periods."
  }
}

variable "location" {
  description = "The Azure region where the resource group will be created"
  type        = string

  validation {
    condition = contains([
      "eastus", "eastus2", "westus", "westus2", "westus3", "centralus", "northcentralus", "southcentralus", "westcentralus",
      "canadacentral", "canadaeast", "brazilsouth", "northeurope", "westeurope", "uksouth", "ukwest",
      "francecentral", "germanywestcentral", "norwayeast", "switzerlandnorth", "swedencentral",
      "eastasia", "southeastasia", "australiaeast", "australiasoutheast", "centralindia", "southindia", "japaneast", "japanwest", "koreacentral"
    ], var.location)
    error_message = "Invalid Azure region specified. Please use a valid Azure region name."
  }
}

variable "lock_level" {
  description = "The level of lock to apply to the resource group (CanNotDelete or ReadOnly). Set to null for no lock."
  type        = string
  default     = null

  validation {
    condition     = var.lock_level == null || contains(["CanNotDelete", "ReadOnly"], var.lock_level)
    error_message = "Lock level must be CanNotDelete, ReadOnly, or null."
  }
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}

  validation {
    condition     = length(var.tags) <= 50
    error_message = "Maximum of 50 tags allowed per resource."
  }
}
