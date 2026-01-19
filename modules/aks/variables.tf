variable "name" {
  description = "The name of the AKS cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][-a-zA-Z0-9]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "AKS cluster name must be between 1 and 63 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the AKS cluster will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix specified when creating the managed cluster"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][-a-zA-Z0-9]{0,43}[a-zA-Z0-9]$", var.dns_prefix))
    error_message = "DNS prefix must be between 1 and 45 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "kubernetes_version" {
  description = "Version of Kubernetes specified when creating the AKS cluster"
  type        = string
  default     = null
}

variable "private_cluster_enabled" {
  description = "Enable private cluster (API server is not publicly accessible)"
  type        = bool
  default     = false
}

variable "sku_tier" {
  description = "The SKU tier for the AKS cluster (Free, Standard, Premium)"
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Standard", "Premium"], var.sku_tier)
    error_message = "SKU tier must be one of: Free, Standard, Premium."
  }
}

variable "workload_identity_enabled" {
  description = "Enable workload identity for the cluster"
  type        = bool
  default     = false
}

variable "oidc_issuer_enabled" {
  description = "Enable OIDC issuer URL (required for workload identity)"
  type        = bool
  default     = false
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy add-on for Kubernetes"
  type        = bool
  default     = false
}

variable "local_account_disabled" {
  description = "Disable local accounts (enforce Azure AD authentication only)"
  type        = bool
  default     = false
}

variable "automatic_channel_upgrade" {
  description = "The upgrade channel for the Kubernetes cluster (patch, rapid, node-image, stable, none)"
  type        = string
  default     = "stable"

  validation {
    condition     = contains(["none", "patch", "rapid", "node-image", "stable"], var.automatic_channel_upgrade)
    error_message = "Automatic channel upgrade must be one of: none, patch, rapid, node-image, stable."
  }
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                = string
    vm_size             = string
    node_count          = optional(number)
    enable_auto_scaling = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    max_pods            = optional(number)
    os_disk_size_gb     = optional(number)
    os_disk_type        = optional(string, "Managed")
    vnet_subnet_id      = optional(string)
    zones               = optional(list(string))
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    max_surge           = optional(string, "10%")
  })

  validation {
    condition     = can(regex("^[a-z0-9]{1,12}$", var.default_node_pool.name))
    error_message = "Node pool name must be lowercase alphanumeric and between 1-12 characters."
  }

  validation {
    condition = var.default_node_pool.enable_auto_scaling == false || (
      var.default_node_pool.min_count != null && var.default_node_pool.max_count != null
    )
    error_message = "When enable_auto_scaling is true, both min_count and max_count must be specified."
  }
}

variable "identity_type" {
  description = "The type of identity used for the managed cluster (SystemAssigned or UserAssigned)"
  type        = string
  default     = "SystemAssigned"
}

variable "network_profile" {
  description = "Network profile configuration"
  type = object({
    network_plugin    = string
    network_policy    = optional(string)
    dns_service_ip    = optional(string)
    service_cidr      = optional(string)
    load_balancer_sku = optional(string, "standard")
  })
  default = {
    network_plugin = "azure"
  }
}

variable "azure_ad_rbac_enabled" {
  description = "Enable Azure Active Directory RBAC"
  type        = bool
  default     = false
}

variable "azure_ad_rbac_config" {
  description = "Azure AD RBAC configuration"
  type = object({
    azure_rbac_enabled     = optional(bool, true)
    admin_group_object_ids = optional(list(string), [])
  })
  default = {}
}

variable "role_based_access_control_enabled" {
  description = "Enable Role Based Access Control"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace for monitoring"
  type        = string
  default     = null
}

variable "additional_node_pools" {
  description = "Map of additional node pools to create"
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = optional(number)
    enable_auto_scaling = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    max_pods            = optional(number)
    os_disk_size_gb     = optional(number)
    os_disk_type        = optional(string, "Managed")
    vnet_subnet_id      = optional(string)
    zones               = optional(list(string))
    mode                = optional(string, "User")
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    max_surge           = optional(string, "10%")
  }))
  default = {}

  validation {
    condition = alltrue([
      for pool in var.additional_node_pools : can(regex("^[a-z0-9]{1,12}$", pool.name))
    ])
    error_message = "All node pool names must be lowercase alphanumeric and between 1-12 characters."
  }

  validation {
    condition = alltrue([
      for pool in var.additional_node_pools :
      pool.enable_auto_scaling == false || (pool.min_count != null && pool.max_count != null)
    ])
    error_message = "When enable_auto_scaling is true for any node pool, both min_count and max_count must be specified."
  }
}

variable "microsoft_defender_enabled" {
  description = "Enable Microsoft Defender for Containers"
  type        = bool
  default     = false
}

variable "key_vault_secrets_provider_enabled" {
  description = "Enable Azure Key Vault Secrets Provider addon"
  type        = bool
  default     = false
}

variable "secret_rotation_enabled" {
  description = "Enable secret rotation for Key Vault Secrets Provider"
  type        = bool
  default     = true
}

variable "secret_rotation_interval" {
  description = "Rotation poll interval for Key Vault Secrets Provider"
  type        = string
  default     = "2m"
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
