variable "name" {
  description = "The name of the NAT Gateway (1-80 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "NAT Gateway name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the NAT Gateway will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the NAT Gateway"
  type        = map(string)
  default     = {}
}

variable "sku_name" {
  description = "The SKU name of the NAT Gateway"
  type        = string
  default     = "Standard"

  validation {
    condition     = var.sku_name == "Standard"
    error_message = "SKU name must be 'Standard'."
  }
}

variable "idle_timeout_in_minutes" {
  description = "The idle timeout in minutes for TCP connections"
  type        = number
  default     = 4

  validation {
    condition     = var.idle_timeout_in_minutes >= 4 && var.idle_timeout_in_minutes <= 120
    error_message = "Idle timeout must be between 4 and 120 minutes."
  }
}

variable "availability_zones" {
  description = "Availability zones for the NAT Gateway"
  type        = list(string)
  default     = null
}

# Public IP Configuration
variable "public_ip_count" {
  description = "Number of public IPs to create and associate with the NAT Gateway"
  type        = number
  default     = 1

  validation {
    condition     = var.public_ip_count >= 1 && var.public_ip_count <= 16
    error_message = "Public IP count must be between 1 and 16."
  }
}

# Public IP Prefix Configuration
variable "create_public_ip_prefix" {
  description = "Create a public IP prefix for the NAT Gateway"
  type        = bool
  default     = false
}

variable "public_ip_prefix_length" {
  description = "The prefix length for the public IP prefix (28-31)"
  type        = number
  default     = 28

  validation {
    condition     = var.public_ip_prefix_length >= 28 && var.public_ip_prefix_length <= 31
    error_message = "Public IP prefix length must be between 28 and 31."
  }
}

# Subnet Associations
variable "subnet_associations" {
  description = "Map of subnet IDs to associate with the NAT Gateway"
  type        = map(string)
  default     = {}
}

# Diagnostic Settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the NAT Gateway"
  type        = bool
  default     = false
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "diagnostic_log_categories" {
  description = "List of diagnostic log categories to enable"
  type        = list(string)
  default     = ["DDoSProtectionNotifications", "DDoSMitigationFlowLogs", "DDoSMitigationReports"]
}

variable "diagnostic_metric_categories" {
  description = "List of diagnostic metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}
