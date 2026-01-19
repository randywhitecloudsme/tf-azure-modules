variable "name" {
  description = "The name of the virtual machine scale set"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}[a-zA-Z0-9]$", var.name))
    error_message = "VMSS name must be between 1 and 64 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the VMSS will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "os_type" {
  description = "The operating system type (Linux or Windows)"
  type        = string

  validation {
    condition     = contains(["Linux", "Windows"], var.os_type)
    error_message = "OS type must be either Linux or Windows."
  }
}

variable "sku" {
  description = "The SKU (size) of the virtual machines in the scale set"
  type        = string
}

variable "instances" {
  description = "The initial number of instances in the scale set"
  type        = number
  default     = 2

  validation {
    condition     = var.instances >= 0 && var.instances <= 1000
    error_message = "Instances must be between 0 and 1000."
  }
}

variable "subnet_id" {
  description = "The ID of the subnet where the VMSS instances will be connected"
  type        = string
}

variable "admin_username" {
  description = "The admin username for the VMSS instances"
  type        = string

  validation {
    condition     = length(var.admin_username) >= 1 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 1 and 20 characters."
  }
}

variable "admin_password" {
  description = "The admin password for the VMSS instances (required for Windows or Linux without SSH keys)"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.admin_password == null || (length(var.admin_password) >= 12 && length(var.admin_password) <= 123)
    error_message = "Admin password must be between 12 and 123 characters when specified."
  }
}

variable "disable_password_authentication" {
  description = "Disable password authentication for Linux VMSS (SSH keys required)"
  type        = bool
  default     = true
}

variable "admin_ssh_keys" {
  description = "List of SSH public keys for Linux VMSS authentication"
  type        = list(string)
  default     = []
}

variable "computer_name_prefix" {
  description = "The computer name prefix for VMSS instances"
  type        = string
  default     = null

  validation {
    condition     = var.computer_name_prefix == null || can(regex("^[a-zA-Z0-9][-a-zA-Z0-9]{0,8}$", var.computer_name_prefix))
    error_message = "Computer name prefix must be between 1 and 9 characters for Windows (15 chars total with suffix)."
  }
}

variable "overprovision" {
  description = "Enable overprovisioning to improve deployment success rate"
  type        = bool
  default     = true
}

variable "single_placement_group" {
  description = "Limit the scale set to a single placement group (max 100 VMs)"
  type        = bool
  default     = false
}

variable "upgrade_mode" {
  description = "The upgrade mode for the scale set (Manual, Automatic, Rolling)"
  type        = string
  default     = "Manual"

  validation {
    condition     = contains(["Manual", "Automatic", "Rolling"], var.upgrade_mode)
    error_message = "Upgrade mode must be Manual, Automatic, or Rolling."
  }
}

variable "zone_balance" {
  description = "Enable zone balancing to evenly distribute VMs across availability zones"
  type        = bool
  default     = true
}

variable "zones" {
  description = "List of availability zones to distribute VMs across"
  type        = list(string)
  default     = null

  validation {
    condition     = var.zones == null || alltrue([for z in var.zones : contains(["1", "2", "3"], z)])
    error_message = "Zones must be 1, 2, or 3."
  }
}

variable "encryption_at_host_enabled" {
  description = "Enable encryption at host (requires subscription feature registration)"
  type        = bool
  default     = false
}

variable "os_disk_caching" {
  description = "The caching type for the OS disk (None, ReadOnly, ReadWrite)"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be None, ReadOnly, or ReadWrite."
  }
}

variable "os_disk_storage_account_type" {
  description = "The storage account type for the OS disk"
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS"], var.os_disk_storage_account_type)
    error_message = "OS disk storage account type must be Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, or Premium_ZRS."
  }
}

variable "os_disk_size_gb" {
  description = "The size of the OS disk in GB"
  type        = number
  default     = null
}

variable "os_disk_write_accelerator_enabled" {
  description = "Enable write accelerator on the OS disk"
  type        = bool
  default     = false
}

variable "ephemeral_os_disk" {
  description = "Use ephemeral OS disk (temp disk)"
  type        = bool
  default     = false
}

variable "ephemeral_os_disk_placement" {
  description = "The placement for ephemeral OS disk (CacheDisk or ResourceDisk)"
  type        = string
  default     = "CacheDisk"

  validation {
    condition     = contains(["CacheDisk", "ResourceDisk"], var.ephemeral_os_disk_placement)
    error_message = "Ephemeral OS disk placement must be CacheDisk or ResourceDisk."
  }
}

variable "disk_encryption_set_id" {
  description = "The ID of the disk encryption set for customer-managed keys"
  type        = string
  default     = null
}

variable "source_image_reference" {
  description = "The source image reference for the VMSS"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

variable "identity_type" {
  description = "The type of managed identity (SystemAssigned, UserAssigned, or SystemAssigned, UserAssigned)"
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = var.identity_type == null || contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "List of user-assigned identity IDs"
  type        = list(string)
  default     = []
}

variable "load_balancer_backend_address_pool_ids" {
  description = "List of load balancer backend address pool IDs"
  type        = list(string)
  default     = []
}

variable "application_gateway_backend_address_pool_ids" {
  description = "List of application gateway backend address pool IDs"
  type        = list(string)
  default     = []
}

variable "health_probe_id" {
  description = "The ID of the health probe for automatic instance repair"
  type        = string
  default     = null
}

variable "disable_automatic_rollback" {
  description = "Disable automatic rollback on failed upgrades"
  type        = bool
  default     = false
}

variable "enable_automatic_os_upgrade" {
  description = "Enable automatic OS upgrades"
  type        = bool
  default     = false
}

variable "enable_automatic_instance_repair" {
  description = "Enable automatic instance repair"
  type        = bool
  default     = false
}

variable "automatic_instance_repair_grace_period" {
  description = "The grace period for automatic instance repair (PT30M to PT90M)"
  type        = string
  default     = "PT30M"

  validation {
    condition     = can(regex("^PT[0-9]+M$", var.automatic_instance_repair_grace_period))
    error_message = "Grace period must be in format PT#M (e.g., PT30M for 30 minutes)."
  }
}

variable "rolling_upgrade_max_batch_instance_percent" {
  description = "The maximum percentage of instances upgraded simultaneously"
  type        = number
  default     = 20

  validation {
    condition     = var.rolling_upgrade_max_batch_instance_percent >= 5 && var.rolling_upgrade_max_batch_instance_percent <= 100
    error_message = "Max batch instance percent must be between 5 and 100."
  }
}

variable "rolling_upgrade_max_unhealthy_instance_percent" {
  description = "The maximum percentage of unhealthy instances allowed"
  type        = number
  default     = 20

  validation {
    condition     = var.rolling_upgrade_max_unhealthy_instance_percent >= 5 && var.rolling_upgrade_max_unhealthy_instance_percent <= 100
    error_message = "Max unhealthy instance percent must be between 5 and 100."
  }
}

variable "rolling_upgrade_max_unhealthy_upgraded_instance_percent" {
  description = "The maximum percentage of unhealthy upgraded instances allowed"
  type        = number
  default     = 20

  validation {
    condition     = var.rolling_upgrade_max_unhealthy_upgraded_instance_percent >= 5 && var.rolling_upgrade_max_unhealthy_upgraded_instance_percent <= 100
    error_message = "Max unhealthy upgraded instance percent must be between 5 and 100."
  }
}

variable "rolling_upgrade_pause_time_between_batches" {
  description = "The wait time between completing batches (PT0S to PT1H)"
  type        = string
  default     = "PT0S"

  validation {
    condition     = can(regex("^PT[0-9]+[SMH]$", var.rolling_upgrade_pause_time_between_batches))
    error_message = "Pause time must be in format PT#S, PT#M, or PT#H."
  }
}

variable "enable_automatic_updates" {
  description = "Enable automatic updates for Windows VMSS"
  type        = bool
  default     = true
}

variable "timezone" {
  description = "The timezone for Windows VMSS"
  type        = string
  default     = "UTC"
}

variable "boot_diagnostics_storage_account_uri" {
  description = "The storage account URI for boot diagnostics"
  type        = string
  default     = null
}

variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics (uses managed storage if storage account URI not provided)"
  type        = bool
  default     = true
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the VMSS"
  type        = bool
  default     = false
}

variable "autoscale_minimum_capacity" {
  description = "The minimum number of instances when autoscaling"
  type        = number
  default     = 2
}

variable "autoscale_default_capacity" {
  description = "The default number of instances when autoscaling"
  type        = number
  default     = 3
}

variable "autoscale_maximum_capacity" {
  description = "The maximum number of instances when autoscaling"
  type        = number
  default     = 10
}

variable "autoscale_rules" {
  description = "List of autoscale rules"
  type = list(object({
    metric_name      = string
    time_grain       = string
    statistic        = string
    time_window      = string
    time_aggregation = string
    operator         = string
    threshold        = number
    scale_direction  = string
    scale_type       = string
    scale_value      = string
    cooldown         = string
  }))
  default = []
}

variable "autoscale_notification_email_admin" {
  description = "Send autoscale notifications to subscription administrators"
  type        = bool
  default     = false
}

variable "autoscale_notification_email_coadmin" {
  description = "Send autoscale notifications to subscription co-administrators"
  type        = bool
  default     = false
}

variable "autoscale_notification_custom_emails" {
  description = "List of custom email addresses for autoscale notifications"
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for monitoring"
  type        = string
  default     = null
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
