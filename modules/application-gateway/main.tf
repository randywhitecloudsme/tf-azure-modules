# Public IP for Application Gateway
resource "azurerm_public_ip" "this" {
  count = var.create_public_ip ? 1 : 0

  name                = "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.availability_zones
  tags                = var.tags
}

# Application Gateway
resource "azurerm_application_gateway" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  enable_http2        = var.enable_http2
  zones               = var.availability_zones
  tags                = var.tags

  sku {
    name     = var.sku_name
    tier     = var.sku_tier
    capacity = var.sku_capacity
  }

  dynamic "autoscale_configuration" {
    for_each = var.autoscale_configuration != null ? [var.autoscale_configuration] : []

    content {
      min_capacity = autoscale_configuration.value.min_capacity
      max_capacity = autoscale_configuration.value.max_capacity
    }
  }

  gateway_ip_configuration {
    name      = "gateway-ip-configuration"
    subnet_id = var.subnet_id
  }

  # Frontend Ports
  dynamic "frontend_port" {
    for_each = var.frontend_ports

    content {
      name = frontend_port.value.name
      port = frontend_port.value.port
    }
  }

  # Frontend IP Configurations
  frontend_ip_configuration {
    name                 = var.frontend_ip_configuration_name
    public_ip_address_id = var.create_public_ip ? azurerm_public_ip.this[0].id : var.public_ip_address_id
  }

  dynamic "frontend_ip_configuration" {
    for_each = var.private_frontend_ip_configuration != null ? [var.private_frontend_ip_configuration] : []

    content {
      name                          = frontend_ip_configuration.value.name
      subnet_id                     = var.subnet_id
      private_ip_address            = frontend_ip_configuration.value.private_ip_address
      private_ip_address_allocation = frontend_ip_configuration.value.private_ip_address_allocation
    }
  }

  # Backend Address Pools
  dynamic "backend_address_pool" {
    for_each = var.backend_address_pools

    content {
      name         = backend_address_pool.value.name
      fqdns        = lookup(backend_address_pool.value, "fqdns", null)
      ip_addresses = lookup(backend_address_pool.value, "ip_addresses", null)
    }
  }

  # Backend HTTP Settings
  dynamic "backend_http_settings" {
    for_each = var.backend_http_settings

    content {
      name                                = backend_http_settings.value.name
      cookie_based_affinity               = backend_http_settings.value.cookie_based_affinity
      affinity_cookie_name                = lookup(backend_http_settings.value, "affinity_cookie_name", null)
      path                                = lookup(backend_http_settings.value, "path", null)
      port                                = backend_http_settings.value.port
      protocol                            = backend_http_settings.value.protocol
      request_timeout                     = backend_http_settings.value.request_timeout
      probe_name                          = lookup(backend_http_settings.value, "probe_name", null)
      host_name                           = lookup(backend_http_settings.value, "host_name", null)
      pick_host_name_from_backend_address = lookup(backend_http_settings.value, "pick_host_name_from_backend_address", false)
      trusted_root_certificate_names      = lookup(backend_http_settings.value, "trusted_root_certificate_names", null)

      dynamic "connection_draining" {
        for_each = lookup(backend_http_settings.value, "connection_draining", null) != null ? [backend_http_settings.value.connection_draining] : []

        content {
          enabled           = connection_draining.value.enabled
          drain_timeout_sec = connection_draining.value.drain_timeout_sec
        }
      }
    }
  }

  # HTTP Listeners
  dynamic "http_listener" {
    for_each = var.http_listeners

    content {
      name                           = http_listener.value.name
      frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
      frontend_port_name             = http_listener.value.frontend_port_name
      protocol                       = http_listener.value.protocol
      host_name                      = lookup(http_listener.value, "host_name", null)
      host_names                     = lookup(http_listener.value, "host_names", null)
      require_sni                    = lookup(http_listener.value, "require_sni", null)
      ssl_certificate_name           = lookup(http_listener.value, "ssl_certificate_name", null)
      firewall_policy_id             = lookup(http_listener.value, "firewall_policy_id", null)

      dynamic "custom_error_configuration" {
        for_each = lookup(http_listener.value, "custom_error_configuration", [])

        content {
          status_code           = custom_error_configuration.value.status_code
          custom_error_page_url = custom_error_configuration.value.custom_error_page_url
        }
      }
    }
  }

  # Request Routing Rules
  dynamic "request_routing_rule" {
    for_each = var.request_routing_rules

    content {
      name                        = request_routing_rule.value.name
      rule_type                   = request_routing_rule.value.rule_type
      http_listener_name          = request_routing_rule.value.http_listener_name
      backend_address_pool_name   = lookup(request_routing_rule.value, "backend_address_pool_name", null)
      backend_http_settings_name  = lookup(request_routing_rule.value, "backend_http_settings_name", null)
      redirect_configuration_name = lookup(request_routing_rule.value, "redirect_configuration_name", null)
      rewrite_rule_set_name       = lookup(request_routing_rule.value, "rewrite_rule_set_name", null)
      url_path_map_name           = lookup(request_routing_rule.value, "url_path_map_name", null)
      priority                    = request_routing_rule.value.priority
    }
  }

  # Health Probes
  dynamic "probe" {
    for_each = var.health_probes

    content {
      name                                      = probe.value.name
      protocol                                  = probe.value.protocol
      path                                      = probe.value.path
      interval                                  = probe.value.interval
      timeout                                   = probe.value.timeout
      unhealthy_threshold                       = probe.value.unhealthy_threshold
      pick_host_name_from_backend_http_settings = lookup(probe.value, "pick_host_name_from_backend_http_settings", false)
      host                                      = lookup(probe.value, "host", null)
      port                                      = lookup(probe.value, "port", null)

      dynamic "match" {
        for_each = lookup(probe.value, "match", null) != null ? [probe.value.match] : []

        content {
          status_code = match.value.status_code
          body        = lookup(match.value, "body", null)
        }
      }
    }
  }

  # SSL Certificates
  dynamic "ssl_certificate" {
    for_each = var.ssl_certificates

    content {
      name                = ssl_certificate.value.name
      data                = lookup(ssl_certificate.value, "data", null)
      password            = lookup(ssl_certificate.value, "password", null)
      key_vault_secret_id = lookup(ssl_certificate.value, "key_vault_secret_id", null)
    }
  }

  # SSL Policy
  dynamic "ssl_policy" {
    for_each = var.ssl_policy != null ? [var.ssl_policy] : []

    content {
      disabled_protocols   = lookup(ssl_policy.value, "disabled_protocols", null)
      policy_type          = lookup(ssl_policy.value, "policy_type", null)
      policy_name          = lookup(ssl_policy.value, "policy_name", null)
      cipher_suites        = lookup(ssl_policy.value, "cipher_suites", null)
      min_protocol_version = lookup(ssl_policy.value, "min_protocol_version", null)
    }
  }

  # WAF Configuration
  dynamic "waf_configuration" {
    for_each = var.waf_configuration != null ? [var.waf_configuration] : []

    content {
      enabled                  = waf_configuration.value.enabled
      firewall_mode            = waf_configuration.value.firewall_mode
      rule_set_type            = waf_configuration.value.rule_set_type
      rule_set_version         = waf_configuration.value.rule_set_version
      file_upload_limit_mb     = lookup(waf_configuration.value, "file_upload_limit_mb", 100)
      request_body_check       = lookup(waf_configuration.value, "request_body_check", true)
      max_request_body_size_kb = lookup(waf_configuration.value, "max_request_body_size_kb", 128)

      dynamic "disabled_rule_group" {
        for_each = lookup(waf_configuration.value, "disabled_rule_groups", [])

        content {
          rule_group_name = disabled_rule_group.value.rule_group_name
          rules           = lookup(disabled_rule_group.value, "rules", null)
        }
      }

      dynamic "exclusion" {
        for_each = lookup(waf_configuration.value, "exclusions", [])

        content {
          match_variable          = exclusion.value.match_variable
          selector_match_operator = lookup(exclusion.value, "selector_match_operator", null)
          selector                = lookup(exclusion.value, "selector", null)
        }
      }
    }
  }

  # URL Path Maps
  dynamic "url_path_map" {
    for_each = var.url_path_maps

    content {
      name                                = url_path_map.value.name
      default_backend_address_pool_name   = lookup(url_path_map.value, "default_backend_address_pool_name", null)
      default_backend_http_settings_name  = lookup(url_path_map.value, "default_backend_http_settings_name", null)
      default_redirect_configuration_name = lookup(url_path_map.value, "default_redirect_configuration_name", null)
      default_rewrite_rule_set_name       = lookup(url_path_map.value, "default_rewrite_rule_set_name", null)

      dynamic "path_rule" {
        for_each = url_path_map.value.path_rules

        content {
          name                        = path_rule.value.name
          paths                       = path_rule.value.paths
          backend_address_pool_name   = lookup(path_rule.value, "backend_address_pool_name", null)
          backend_http_settings_name  = lookup(path_rule.value, "backend_http_settings_name", null)
          redirect_configuration_name = lookup(path_rule.value, "redirect_configuration_name", null)
          rewrite_rule_set_name       = lookup(path_rule.value, "rewrite_rule_set_name", null)
          firewall_policy_id          = lookup(path_rule.value, "firewall_policy_id", null)
        }
      }
    }
  }

  # Redirect Configurations
  dynamic "redirect_configuration" {
    for_each = var.redirect_configurations

    content {
      name                 = redirect_configuration.value.name
      redirect_type        = redirect_configuration.value.redirect_type
      target_listener_name = lookup(redirect_configuration.value, "target_listener_name", null)
      target_url           = lookup(redirect_configuration.value, "target_url", null)
      include_path         = lookup(redirect_configuration.value, "include_path", true)
      include_query_string = lookup(redirect_configuration.value, "include_query_string", true)
    }
  }

  # Identity
  dynamic "identity" {
    for_each = var.identity != null ? [var.identity] : []

    content {
      type         = identity.value.type
      identity_ids = lookup(identity.value, "identity_ids", null)
    }
  }

  lifecycle {
    prevent_destroy = false # Set to true for production
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "this" {
  count = var.enable_diagnostics ? 1 : 0

  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_application_gateway.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = var.diagnostic_log_categories

    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_metric_categories

    content {
      category = metric.value
      enabled  = true
    }
  }
}
