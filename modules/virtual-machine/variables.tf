variable "name" {
  description = "The name of the virtual machine"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][-a-zA-Z0-9]{0,62}[a-zA-Z0-9]$", var.name))
    error_message = "VM name must be between 1 and 64 characters, start and end with alphanumeric, and contain only alphanumerics and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the VM will be created"
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

variable "vm_size" {
  description = "The size of the virtual machine"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet where the VM NIC will be attached"
  type        = string
}

variable "private_ip_address_allocation" {
  description = "The allocation method for the private IP address (Dynamic or Static)"
  type        = string
  default     = "Dynamic"

  validation {
    condition     = contains(["Dynamic", "Static"], var.private_ip_address_allocation)
    error_message = "Private IP address allocation must be either Dynamic or Static."
  }
}

variable "private_ip_address" {
  description = "The static private IP address (required if allocation is Static)"
  type        = string
  default     = null
}

variable "public_ip_address_id" {
  description = "The ID of the public IP address to associate with the NIC"
  type        = string
  default     = null
}

variable "admin_username" {
  description = "The admin username for the VM"
  type        = string

  validation {
    condition     = length(var.admin_username) >= 1 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 1 and 20 characters."
  }
}

variable "admin_password" {
  description = "The admin password for the VM (required for Windows or Linux without SSH keys)"
  type        = string
  default     = null
  sensitive   = true

  validation {
    condition     = var.admin_password == null || (length(var.admin_password) >= 12 && length(var.admin_password) <= 123)
    error_message = "Admin password must be between 12 and 123 characters when specified."
  }
}

variable "disable_password_authentication" {
  description = "Disable password authentication for Linux VMs (SSH keys required)"
  type        = bool
  default     = true
}

variable "admin_ssh_keys" {
  description = "List of SSH public keys for Linux VM authentication"
  type        = list(string)
  default     = []
}

variable "computer_name" {
  description = "The computer name (hostname) for the VM"
  type        = string
  default     = null
}

variable "availability_set_id" {
  description = "The ID of the availability set to place the VM in"
  type        = string
  default     = null
}

variable "zone" {
  description = "The availability zone to place the VM in (1, 2, or 3)"
  type        = string
  default     = null

  validation {
    condition     = var.zone == null || contains(["1", "2", "3"], var.zone)
    error_message = "Zone must be 1, 2, or 3."
  }
}

variable "patch_mode" {
  description = "The patch mode for the VM (AutomaticByPlatform, AutomaticByOS, Manual, ImageDefault)"
  type        = string
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["AutomaticByPlatform", "AutomaticByOS", "Manual", "ImageDefault"], var.patch_mode)
    error_message = "Patch mode must be one of: AutomaticByPlatform, AutomaticByOS, Manual, ImageDefault."
  }
}

variable "patch_assessment_mode" {
  description = "The patch assessment mode (AutomaticByPlatform or ImageDefault)"
  type        = string
  default     = "AutomaticByPlatform"

  validation {
    condition     = contains(["AutomaticByPlatform", "ImageDefault"], var.patch_assessment_mode)
    error_message = "Patch assessment mode must be AutomaticByPlatform or ImageDefault."
  }
}

variable "enable_automatic_updates" {
  description = "Enable automatic updates for Windows VMs"
  type        = bool
  default     = true
}

variable "timezone" {
  description = "The timezone for Windows VMs"
  type        = string
  default     = "UTC"
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
  description = "The storage account type for the OS disk (Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS)"
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
  description = "Enable write accelerator on the OS disk (Premium storage only)"
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
  description = "The source image reference for the VM"
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
  description = "List of user-assigned identity IDs (required for UserAssigned identity type)"
  type        = list(string)
  default     = []
}

variable "data_disks" {
  description = "Map of data disks to attach to the VM"
  type = map(object({
    disk_size_gb         = number
    storage_account_type = string
    lun                  = number
    caching              = optional(string, "ReadWrite")
    create_option        = optional(string, "Empty")
  }))
  default = {}

  validation {
    condition = alltrue([
      for disk in var.data_disks : contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "StandardSSD_ZRS", "Premium_ZRS", "UltraSSD_LRS"], disk.storage_account_type)
    ])
    error_message = "Data disk storage account type must be Standard_LRS, StandardSSD_LRS, Premium_LRS, StandardSSD_ZRS, Premium_ZRS, or UltraSSD_LRS."
  }

  validation {
    condition = alltrue([
      for disk in var.data_disks : contains(["None", "ReadOnly", "ReadWrite"], disk.caching)
    ])
    error_message = "Data disk caching must be None, ReadOnly, or ReadWrite."
  }
}

variable "boot_diagnostics_storage_account_uri" {
  description = "The storage account URI for boot diagnostics (managed storage used if not specified)"
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace for monitoring"
  type        = string
  default     = null
}

variable "enable_monitoring_agent" {
  description = "Enable Azure Monitor Agent extension"
  type        = bool
  default     = true
}

variable "enable_dependency_agent" {
  description = "Enable Dependency Agent for VM Insights"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A mapping of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
