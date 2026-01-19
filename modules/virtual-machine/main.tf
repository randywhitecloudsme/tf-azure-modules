resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation
    private_ip_address            = var.private_ip_address
    public_ip_address_id          = var.public_ip_address_id
  }

  tags = var.tags
}

resource "azurerm_linux_virtual_machine" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  size                            = var.vm_size
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication
  admin_password                  = var.disable_password_authentication ? null : var.admin_password
  computer_name                   = var.computer_name != null ? var.computer_name : var.name
  availability_set_id             = var.availability_set_id
  zone                            = var.zone
  patch_mode                      = var.patch_mode
  patch_assessment_mode           = var.patch_assessment_mode
  encryption_at_host_enabled      = var.encryption_at_host_enabled

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? var.admin_ssh_keys : []

    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  os_disk {
    name                      = "${var.name}-osdisk"
    caching                   = var.os_disk_caching
    storage_account_type      = var.os_disk_storage_account_type
    disk_size_gb              = var.os_disk_size_gb
    disk_encryption_set_id    = var.disk_encryption_set_id
    write_accelerator_enabled = var.os_disk_write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.ephemeral_os_disk ? [1] : []

      content {
        option    = "Local"
        placement = var.ephemeral_os_disk_placement
      }
    }
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []

    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  size                       = var.vm_size
  admin_username             = var.admin_username
  admin_password             = var.admin_password
  computer_name              = var.computer_name != null ? var.computer_name : var.name
  availability_set_id        = var.availability_set_id
  zone                       = var.zone
  patch_mode                 = var.patch_mode
  patch_assessment_mode      = var.patch_assessment_mode
  enable_automatic_updates   = var.enable_automatic_updates
  timezone                   = var.timezone
  encryption_at_host_enabled = var.encryption_at_host_enabled

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    name                      = "${var.name}-osdisk"
    caching                   = var.os_disk_caching
    storage_account_type      = var.os_disk_storage_account_type
    disk_size_gb              = var.os_disk_size_gb
    disk_encryption_set_id    = var.disk_encryption_set_id
    write_accelerator_enabled = var.os_disk_write_accelerator_enabled

    dynamic "diff_disk_settings" {
      for_each = var.ephemeral_os_disk ? [1] : []

      content {
        option    = "Local"
        placement = var.ephemeral_os_disk_placement
      }
    }
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  dynamic "identity" {
    for_each = var.identity_type != null ? [1] : []

    content {
      type         = var.identity_type
      identity_ids = var.identity_type == "UserAssigned" || var.identity_type == "SystemAssigned, UserAssigned" ? var.identity_ids : null
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null ? [1] : []

    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      admin_password
    ]
  }
}

# Data Disks
resource "azurerm_managed_disk" "this" {
  for_each = var.data_disks

  name                   = "${var.name}-${each.key}"
  location               = var.location
  resource_group_name    = var.resource_group_name
  storage_account_type   = each.value.storage_account_type
  create_option          = lookup(each.value, "create_option", "Empty")
  disk_size_gb           = each.value.disk_size_gb
  disk_encryption_set_id = var.disk_encryption_set_id
  zone                   = var.zone

  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "this" {
  for_each = var.data_disks

  managed_disk_id    = azurerm_managed_disk.this[each.key].id
  virtual_machine_id = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  lun                = each.value.lun
  caching            = lookup(each.value, "caching", "ReadWrite")
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# VM Extensions
resource "azurerm_virtual_machine_extension" "monitoring" {
  count = var.enable_monitoring_agent ? 1 : 0

  name                       = "AzureMonitorAgent"
  virtual_machine_id         = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = var.os_type == "Linux" ? "AzureMonitorLinuxAgent" : "AzureMonitorWindowsAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}

resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count = var.enable_dependency_agent ? 1 : 0

  name                       = "DependencyAgent"
  virtual_machine_id         = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = var.os_type == "Linux" ? "DependencyAgentLinux" : "DependencyAgentWindows"
  type_handler_version       = "9.10"
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true

  tags = var.tags

  depends_on = [azurerm_virtual_machine_extension.monitoring]
}
