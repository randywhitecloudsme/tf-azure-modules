resource "azurerm_linux_virtual_machine_scale_set" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                            = var.name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  sku                             = var.sku
  instances                       = var.instances
  admin_username                  = var.admin_username
  disable_password_authentication = var.disable_password_authentication
  admin_password                  = var.disable_password_authentication ? null : var.admin_password
  computer_name_prefix            = var.computer_name_prefix != null ? var.computer_name_prefix : var.name
  overprovision                   = var.overprovision
  single_placement_group          = var.single_placement_group
  upgrade_mode                    = var.upgrade_mode
  zone_balance                    = var.zone_balance
  zones                           = var.zones
  encryption_at_host_enabled      = var.encryption_at_host_enabled

  dynamic "admin_ssh_key" {
    for_each = var.disable_password_authentication ? var.admin_ssh_keys : []

    content {
      username   = var.admin_username
      public_key = admin_ssh_key.value
    }
  }

  network_interface {
    name    = "${var.name}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.load_balancer_backend_address_pool_ids
      application_gateway_backend_address_pool_ids = var.application_gateway_backend_address_pool_ids
    }
  }

  os_disk {
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

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.upgrade_mode == "Automatic" || var.upgrade_mode == "Rolling" ? [1] : []

    content {
      disable_automatic_rollback  = var.disable_automatic_rollback
      enable_automatic_os_upgrade = var.enable_automatic_os_upgrade
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.enable_automatic_instance_repair ? [1] : []

    content {
      enabled      = true
      grace_period = var.automatic_instance_repair_grace_period
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.upgrade_mode == "Rolling" ? [1] : []

    content {
      max_batch_instance_percent              = var.rolling_upgrade_max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_pause_time_between_batches
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null || var.enable_boot_diagnostics ? [1] : []

    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  health_probe_id = var.health_probe_id

  tags = var.tags

  lifecycle {
    ignore_changes = [
      instances,
      admin_password
    ]
  }
}

resource "azurerm_windows_virtual_machine_scale_set" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                     = var.name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  sku                      = var.sku
  instances                = var.instances
  admin_username           = var.admin_username
  admin_password           = var.admin_password
  computer_name_prefix     = var.computer_name_prefix != null ? var.computer_name_prefix : var.name
  overprovision            = var.overprovision
  single_placement_group   = var.single_placement_group
  upgrade_mode             = var.upgrade_mode
  zone_balance             = var.zone_balance
  zones                    = var.zones
  enable_automatic_updates = var.enable_automatic_updates
  timezone                 = var.timezone
  encryption_at_host_enabled = var.encryption_at_host_enabled

  network_interface {
    name    = "${var.name}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                              = var.subnet_id
      load_balancer_backend_address_pool_ids = var.load_balancer_backend_address_pool_ids
      application_gateway_backend_address_pool_ids = var.application_gateway_backend_address_pool_ids
    }
  }

  os_disk {
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

  dynamic "automatic_os_upgrade_policy" {
    for_each = var.upgrade_mode == "Automatic" || var.upgrade_mode == "Rolling" ? [1] : []

    content {
      disable_automatic_rollback  = var.disable_automatic_rollback
      enable_automatic_os_upgrade = var.enable_automatic_os_upgrade
    }
  }

  dynamic "automatic_instance_repair" {
    for_each = var.enable_automatic_instance_repair ? [1] : []

    content {
      enabled      = true
      grace_period = var.automatic_instance_repair_grace_period
    }
  }

  dynamic "rolling_upgrade_policy" {
    for_each = var.upgrade_mode == "Rolling" ? [1] : []

    content {
      max_batch_instance_percent              = var.rolling_upgrade_max_batch_instance_percent
      max_unhealthy_instance_percent          = var.rolling_upgrade_max_unhealthy_instance_percent
      max_unhealthy_upgraded_instance_percent = var.rolling_upgrade_max_unhealthy_upgraded_instance_percent
      pause_time_between_batches              = var.rolling_upgrade_pause_time_between_batches
    }
  }

  dynamic "boot_diagnostics" {
    for_each = var.boot_diagnostics_storage_account_uri != null || var.enable_boot_diagnostics ? [1] : []

    content {
      storage_account_uri = var.boot_diagnostics_storage_account_uri
    }
  }

  health_probe_id = var.health_probe_id

  tags = var.tags

  lifecycle {
    ignore_changes = [
      instances,
      admin_password
    ]
  }
}

# Autoscale Settings
resource "azurerm_monitor_autoscale_setting" "this" {
  count = var.enable_autoscaling ? 1 : 0

  name                = "${var.name}-autoscale"
  location            = var.location
  resource_group_name = var.resource_group_name
  target_resource_id  = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].id : azurerm_windows_virtual_machine_scale_set.this[0].id

  profile {
    name = "default"

    capacity {
      default = var.autoscale_default_capacity
      minimum = var.autoscale_minimum_capacity
      maximum = var.autoscale_maximum_capacity
    }

    dynamic "rule" {
      for_each = var.autoscale_rules

      content {
        metric_trigger {
          metric_name        = rule.value.metric_name
          metric_resource_id = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].id : azurerm_windows_virtual_machine_scale_set.this[0].id
          time_grain         = rule.value.time_grain
          statistic          = rule.value.statistic
          time_window        = rule.value.time_window
          time_aggregation   = rule.value.time_aggregation
          operator           = rule.value.operator
          threshold          = rule.value.threshold
        }

        scale_action {
          direction = rule.value.scale_direction
          type      = rule.value.scale_type
          value     = rule.value.scale_value
          cooldown  = rule.value.cooldown
        }
      }
    }
  }

  notification {
    email {
      send_to_subscription_administrator    = var.autoscale_notification_email_admin
      send_to_subscription_co_administrator = var.autoscale_notification_email_coadmin
      custom_emails                         = var.autoscale_notification_custom_emails
    }
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].id : azurerm_windows_virtual_machine_scale_set.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
