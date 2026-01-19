variable "name" {
  description = "The name of the Container Registry (5-50 characters, alphanumeric only)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]{5,50}$", var.name))
    error_message = "Container Registry name must be 5-50 characters and alphanumeric only."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "location" {
  description = "The Azure region where the Container Registry will be created"
  type        = string
}

variable "sku" {
  description = "The SKU name of the container registry (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.sku)
    error_message = "SKU must be Basic, Standard, or Premium."
  }
}

variable "admin_enabled" {
  description = "Specifies whether the admin user is enabled"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Whether public network access is allowed for the container registry"
  type        = bool
  default     = true
}

variable "zone_redundancy_enabled" {
  description = "Whether zone redundancy is enabled (Premium SKU only)"
  type        = bool
  default     = false
}

variable "encryption_enabled" {
  description = "Enable encryption using customer-managed keys (Premium SKU only)"
  type        = bool
  default     = false
}

variable "encryption_key_vault_key_id" {
  description = "Key Vault Key ID for encryption (required if encryption_enabled is true)"
  type        = string
  default     = null
}

variable "encryption_identity_client_id" {
  description = "Client ID of user-assigned identity for encryption"
  type        = string
  default     = null
}

variable "enable_system_assigned_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = false
}

variable "enable_private_endpoint" {
  description = "Enable private endpoint for Container Registry"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint (required if enable_private_endpoint is true)"
  type        = string
  default     = null
}

variable "private_dns_zone_ids" {
  description = "List of private DNS zone IDs for private endpoint"
  type        = list(string)
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "user_assigned_identity_ids" {
  description = "List of user-assigned identity IDs"
  type        = list(string)
  default     = null
}

variable "georeplications" {
  description = "List of geo-replication configurations (Premium SKU only)"
  type = list(object({
    location                = string
    zone_redundancy_enabled = optional(bool, false)
    tags                    = optional(map(string))
  }))
  default = []
}

variable "network_rule_set" {
  description = "Network rule set configuration (Premium SKU only)"
  type = object({
    default_action             = string
    ip_rules                   = optional(list(string), [])
    virtual_network_subnet_ids = optional(list(string), [])
  })
  default = null
}

variable "retention_policy" {
  description = "Retention policy configuration (Premium SKU only)"
  type = object({
    days    = optional(number, 7)
    enabled = optional(bool, false)
  })
  default = null
}

variable "trust_policy_enabled" {
  description = "Whether trust policy is enabled (Premium SKU only)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
