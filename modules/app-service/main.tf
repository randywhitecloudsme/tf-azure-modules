resource "azurerm_service_plan" "this" {
  name                = var.service_plan_name
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_linux_web_app" "this" {
  count = var.os_type == "Linux" ? 1 : 0

  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    vnet_route_all_enabled            = var.vnet_integration_enabled
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []

      content {
        docker_image_name = lookup(application_stack.value, "docker_image_name", null)
        dotnet_version    = lookup(application_stack.value, "dotnet_version", null)
        java_version      = lookup(application_stack.value, "java_version", null)
        node_version      = lookup(application_stack.value, "node_version", null)
        python_version    = lookup(application_stack.value, "python_version", null)
        php_version       = lookup(application_stack.value, "php_version", null)
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  https_only = var.https_only

  dynamic "identity" {
    for_each = var.enable_system_assigned_identity ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      tags["hidden-link: /app-insights-conn-string"]
    ]
  }
}

resource "azurerm_windows_web_app" "this" {
  count = var.os_type == "Windows" ? 1 : 0

  name                = var.app_name
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id

  site_config {
    always_on                         = var.always_on
    ftps_state                        = var.ftps_state
    http2_enabled                     = var.http2_enabled
    minimum_tls_version               = var.minimum_tls_version
    vnet_route_all_enabled            = var.vnet_integration_enabled
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_eviction_time_in_min

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []

      content {
        current_stack  = lookup(application_stack.value, "current_stack", null)
        dotnet_version = lookup(application_stack.value, "dotnet_version", null)
        java_version   = lookup(application_stack.value, "java_version", null)
        node_version   = lookup(application_stack.value, "node_version", null)
        python_version = lookup(application_stack.value, "python_version", null)
        php_version    = lookup(application_stack.value, "php_version", null)
      }
    }
  }

  app_settings = var.app_settings

  dynamic "connection_string" {
    for_each = var.connection_strings

    content {
      name  = connection_string.value.name
      type  = connection_string.value.type
      value = connection_string.value.value
    }
  }

  https_only = var.https_only

  dynamic "identity" {
    for_each = var.enable_system_assigned_identity ? [1] : []

    content {
      type = "SystemAssigned"
    }
  }

  tags = var.tags

  lifecycle {
    ignore_changes = [
      tags["hidden-link: /app-insights-instrumentation-key"],
      tags["hidden-link: /app-insights-resource-id"],
      tags["hidden-link: /app-insights-conn-string"]
    ]
  }
}

# VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  count = var.vnet_integration_enabled && var.vnet_integration_subnet_id != null ? 1 : 0

  app_service_id = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  subnet_id      = var.vnet_integration_subnet_id
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.log_analytics_workspace_id != null ? 1 : 0

  name                       = "${var.app_name}-diagnostics"
  target_resource_id         = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
