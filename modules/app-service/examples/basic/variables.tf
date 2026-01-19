variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-appservice-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "service_plan_name" {
  description = "The name of the Service Plan"
  type        = string
  default     = "example-service-plan"
}

variable "app_name" {
  description = "The name of the App Service"
  type        = string
  default     = "example-app-service-12345"
}

variable "os_type" {
  description = "The OS type (Linux or Windows)"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "The SKU for the Service Plan"
  type        = string
  default     = "B1"
}

variable "application_stack" {
  description = "Application stack configuration"
  type        = map(string)
  default = {
    node_version = "18-lts"
  }
}

variable "app_settings" {
  description = "Map of app settings"
  type        = map(string)
  default = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
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
