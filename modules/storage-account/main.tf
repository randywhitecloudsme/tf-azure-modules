resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  access_tier              = var.access_tier

  enable_https_traffic_only       = var.enable_https_traffic_only
  min_tls_version                 = var.min_tls_version
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  shared_access_key_enabled       = var.shared_access_key_enabled
  public_network_access_enabled   = var.public_network_access_enabled

  # Infrastructure encryption for double encryption
  infrastructure_encryption_enabled = var.infrastructure_encryption_enabled

  dynamic "blob_properties" {
    for_each = var.blob_properties != null ? [var.blob_properties] : []

    content {
      versioning_enabled       = lookup(blob_properties.value, "versioning_enabled", false)
      change_feed_enabled      = lookup(blob_properties.value, "change_feed_enabled", false)
      last_access_time_enabled = lookup(blob_properties.value, "last_access_time_enabled", false)

      dynamic "delete_retention_policy" {
        for_each = lookup(blob_properties.value, "delete_retention_policy", null) != null ? [blob_properties.value.delete_retention_policy] : []

        content {
          days = delete_retention_policy.value.days
        }
      }

      dynamic "container_delete_retention_policy" {
        for_each = lookup(blob_properties.value, "container_delete_retention_policy", null) != null ? [blob_properties.value.container_delete_retention_policy] : []

        content {
          days = container_delete_retention_policy.value.days
        }
      }
    }
  }

  dynamic "network_rules" {
    for_each = var.network_rules != null ? [var.network_rules] : []

    content {
      default_action             = network_rules.value.default_action
      bypass                     = lookup(network_rules.value, "bypass", ["AzureServices"])
      ip_rules                   = lookup(network_rules.value, "ip_rules", [])
      virtual_network_subnet_ids = lookup(network_rules.value, "virtual_network_subnet_ids", [])
    }
  }

  dynamic "identity" {
    for_each = var.enable_system_assigned_identity ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

resource "azurerm_storage_container" "this" {
  for_each = var.containers

  name                  = each.value.name
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = lookup(each.value, "container_access_type", "private")
}

# Private Endpoints
resource "azurerm_private_endpoint" "blob" {
  count = var.enable_private_endpoint ? 1 : 0

  name                = "${var.name}-blob-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-blob-psc"
    private_connection_resource_id = azurerm_storage_account.this.id
    is_manual_connection           = false
    subresource_names              = ["blob"]
  }

  tags = var.tags
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "StorageRead"
  }

  enabled_log {
    category = "StorageWrite"
  }

  enabled_log {
    category = "StorageDelete"
  }

  metric {
    category = "Transaction"
    enabled  = true
  }

  metric {
    category = "Capacity"
    enabled  = true
  }
}

# Lifecycle Management Policy
resource "azurerm_storage_management_policy" "this" {
  count = var.lifecycle_rules != null ? 1 : 0

  storage_account_id = azurerm_storage_account.this.id

  dynamic "rule" {
    for_each = var.lifecycle_rules

    content {
      name    = rule.value.name
      enabled = lookup(rule.value, "enabled", true)

      filters {
        prefix_match = lookup(rule.value, "prefix_match", [])
        blob_types   = lookup(rule.value, "blob_types", ["blockBlob"])
      }

      actions {
        dynamic "base_blob" {
          for_each = lookup(rule.value, "base_blob", null) != null ? [rule.value.base_blob] : []

          content {
            tier_to_cool_after_days_since_modification_greater_than    = lookup(base_blob.value, "tier_to_cool_after_days", null)
            tier_to_archive_after_days_since_modification_greater_than = lookup(base_blob.value, "tier_to_archive_after_days", null)
            delete_after_days_since_modification_greater_than          = lookup(base_blob.value, "delete_after_days", null)
          }
        }

        dynamic "snapshot" {
          for_each = lookup(rule.value, "snapshot", null) != null ? [rule.value.snapshot] : []

          content {
            delete_after_days_since_creation_greater_than = snapshot.value.delete_after_days
          }
        }
      }
    }
  }
}
