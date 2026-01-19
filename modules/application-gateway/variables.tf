variable "name" {
  description = "The name of the application gateway (1-80 characters)"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "Application Gateway name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the application gateway will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the application gateway"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The ID of the subnet for the application gateway"
  type        = string
}

# SKU Configuration
variable "sku_name" {
  description = "The SKU name of the application gateway"
  type        = string
  default     = "Standard_v2"

  validation {
    condition = contains([
      "Standard_Small", "Standard_Medium", "Standard_Large",
      "WAF_Medium", "WAF_Large",
      "Standard_v2", "WAF_v2"
    ], var.sku_name)
    error_message = "Invalid SKU name."
  }
}

variable "sku_tier" {
  description = "The SKU tier of the application gateway"
  type        = string
  default     = "Standard_v2"

  validation {
    condition     = contains(["Standard", "Standard_v2", "WAF", "WAF_v2"], var.sku_tier)
    error_message = "SKU tier must be one of: Standard, Standard_v2, WAF, WAF_v2."
  }
}

variable "sku_capacity" {
  description = "The capacity (instance count) of the application gateway"
  type        = number
  default     = null

  validation {
    condition     = var.sku_capacity == null || (var.sku_capacity >= 1 && var.sku_capacity <= 125)
    error_message = "SKU capacity must be between 1 and 125."
  }
}

variable "autoscale_configuration" {
  description = "Autoscale configuration for the application gateway"
  type = object({
    min_capacity = number
    max_capacity = number
  })
  default = {
    min_capacity = 2
    max_capacity = 10
  }

  validation {
    condition = var.autoscale_configuration == null || (
      var.autoscale_configuration.min_capacity >= 0 &&
      var.autoscale_configuration.max_capacity >= var.autoscale_configuration.min_capacity &&
      var.autoscale_configuration.max_capacity <= 125
    )
    error_message = "Min capacity must be >= 0, max capacity must be >= min capacity and <= 125."
  }
}

variable "availability_zones" {
  description = "Availability zones for the application gateway"
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "enable_http2" {
  description = "Enable HTTP/2 support"
  type        = bool
  default     = true
}

# Public IP Configuration
variable "create_public_ip" {
  description = "Create a new public IP for the application gateway"
  type        = bool
  default     = true
}

variable "public_ip_address_id" {
  description = "ID of an existing public IP (if not creating a new one)"
  type        = string
  default     = null
}

# Frontend Configuration
variable "frontend_ip_configuration_name" {
  description = "Name of the frontend IP configuration"
  type        = string
  default     = "frontend-ip-config"
}

variable "private_frontend_ip_configuration" {
  description = "Private frontend IP configuration"
  type = object({
    name                          = string
    private_ip_address            = string
    private_ip_address_allocation = string
  })
  default = null
}

variable "frontend_ports" {
  description = "List of frontend ports"
  type = list(object({
    name = string
    port = number
  }))
  default = [
    {
      name = "http"
      port = 80
    },
    {
      name = "https"
      port = 443
    }
  ]

  validation {
    condition = alltrue([
      for port in var.frontend_ports : (
        port.port >= 1 && port.port <= 65535
      )
    ])
    error_message = "Frontend port must be between 1 and 65535."
  }
}

# Backend Configuration
variable "backend_address_pools" {
  description = "List of backend address pools"
  type = list(object({
    name         = string
    fqdns        = optional(list(string))
    ip_addresses = optional(list(string))
  }))
}

variable "backend_http_settings" {
  description = "List of backend HTTP settings"
  type = list(object({
    name                                = string
    cookie_based_affinity               = string
    affinity_cookie_name                = optional(string)
    path                                = optional(string)
    port                                = number
    protocol                            = string
    request_timeout                     = number
    probe_name                          = optional(string)
    host_name                           = optional(string)
    pick_host_name_from_backend_address = optional(bool)
    trusted_root_certificate_names      = optional(list(string))
    connection_draining = optional(object({
      enabled           = bool
      drain_timeout_sec = number
    }))
  }))

  validation {
    condition = alltrue([
      for setting in var.backend_http_settings : (
        contains(["Enabled", "Disabled"], setting.cookie_based_affinity)
      )
    ])
    error_message = "Cookie based affinity must be either 'Enabled' or 'Disabled'."
  }

  validation {
    condition = alltrue([
      for setting in var.backend_http_settings : (
        contains(["Http", "Https"], setting.protocol)
      )
    ])
    error_message = "Protocol must be either 'Http' or 'Https'."
  }
}

# HTTP Listeners
variable "http_listeners" {
  description = "List of HTTP listeners"
  type = list(object({
    name                           = string
    frontend_ip_configuration_name = string
    frontend_port_name             = string
    protocol                       = string
    host_name                      = optional(string)
    host_names                     = optional(list(string))
    require_sni                    = optional(bool)
    ssl_certificate_name           = optional(string)
    firewall_policy_id             = optional(string)
    custom_error_configuration = optional(list(object({
      status_code           = string
      custom_error_page_url = string
    })))
  }))

  validation {
    condition = alltrue([
      for listener in var.http_listeners : (
        contains(["Http", "Https"], listener.protocol)
      )
    ])
    error_message = "Listener protocol must be either 'Http' or 'Https'."
  }
}

# Request Routing Rules
variable "request_routing_rules" {
  description = "List of request routing rules"
  type = list(object({
    name                        = string
    rule_type                   = string
    http_listener_name          = string
    backend_address_pool_name   = optional(string)
    backend_http_settings_name  = optional(string)
    redirect_configuration_name = optional(string)
    rewrite_rule_set_name       = optional(string)
    url_path_map_name           = optional(string)
    priority                    = number
  }))

  validation {
    condition = alltrue([
      for rule in var.request_routing_rules : (
        contains(["Basic", "PathBasedRouting"], rule.rule_type)
      )
    ])
    error_message = "Rule type must be either 'Basic' or 'PathBasedRouting'."
  }

  validation {
    condition = alltrue([
      for rule in var.request_routing_rules : (
        rule.priority >= 1 && rule.priority <= 20000
      )
    ])
    error_message = "Priority must be between 1 and 20000."
  }
}

# Health Probes
variable "health_probes" {
  description = "List of health probes"
  type = list(object({
    name                                      = string
    protocol                                  = string
    path                                      = string
    interval                                  = number
    timeout                                   = number
    unhealthy_threshold                       = number
    pick_host_name_from_backend_http_settings = optional(bool)
    host                                      = optional(string)
    port                                      = optional(number)
    match = optional(object({
      status_code = list(string)
      body        = optional(string)
    }))
  }))
  default = []

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        contains(["Http", "Https"], probe.protocol)
      )
    ])
    error_message = "Probe protocol must be either 'Http' or 'Https'."
  }

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        probe.interval >= 1 && probe.interval <= 86400
      )
    ])
    error_message = "Probe interval must be between 1 and 86400 seconds."
  }

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        probe.timeout >= 1 && probe.timeout <= 86400
      )
    ])
    error_message = "Probe timeout must be between 1 and 86400 seconds."
  }

  validation {
    condition = alltrue([
      for probe in var.health_probes : (
        probe.unhealthy_threshold >= 1 && probe.unhealthy_threshold <= 20
      )
    ])
    error_message = "Unhealthy threshold must be between 1 and 20."
  }
}

# SSL Configuration
variable "ssl_certificates" {
  description = "List of SSL certificates"
  type = list(object({
    name                = string
    data                = optional(string)
    password            = optional(string)
    key_vault_secret_id = optional(string)
  }))
  default   = []
  sensitive = true
}

variable "ssl_policy" {
  description = "SSL policy configuration"
  type = object({
    disabled_protocols   = optional(list(string))
    policy_type          = optional(string)
    policy_name          = optional(string)
    cipher_suites        = optional(list(string))
    min_protocol_version = optional(string)
  })
  default = null
}

# WAF Configuration
variable "waf_configuration" {
  description = "WAF configuration (only for WAF SKUs)"
  type = object({
    enabled                  = bool
    firewall_mode            = string
    rule_set_type            = string
    rule_set_version         = string
    file_upload_limit_mb     = optional(number)
    request_body_check       = optional(bool)
    max_request_body_size_kb = optional(number)
    disabled_rule_groups = optional(list(object({
      rule_group_name = string
      rules           = optional(list(string))
    })))
    exclusions = optional(list(object({
      match_variable          = string
      selector_match_operator = optional(string)
      selector                = optional(string)
    })))
  })
  default = null

  validation {
    condition = var.waf_configuration == null || (
      contains(["Detection", "Prevention"], var.waf_configuration.firewall_mode)
    )
    error_message = "WAF firewall mode must be either 'Detection' or 'Prevention'."
  }
}

# URL Path Maps
variable "url_path_maps" {
  description = "List of URL path maps"
  type = list(object({
    name                                = string
    default_backend_address_pool_name   = optional(string)
    default_backend_http_settings_name  = optional(string)
    default_redirect_configuration_name = optional(string)
    default_rewrite_rule_set_name       = optional(string)
    path_rules = list(object({
      name                        = string
      paths                       = list(string)
      backend_address_pool_name   = optional(string)
      backend_http_settings_name  = optional(string)
      redirect_configuration_name = optional(string)
      rewrite_rule_set_name       = optional(string)
      firewall_policy_id          = optional(string)
    }))
  }))
  default = []
}

# Redirect Configurations
variable "redirect_configurations" {
  description = "List of redirect configurations"
  type = list(object({
    name                 = string
    redirect_type        = string
    target_listener_name = optional(string)
    target_url           = optional(string)
    include_path         = optional(bool)
    include_query_string = optional(bool)
  }))
  default = []

  validation {
    condition = alltrue([
      for config in var.redirect_configurations : (
        contains(["Permanent", "Temporary", "Found", "SeeOther"], config.redirect_type)
      )
    ])
    error_message = "Redirect type must be one of: Permanent, Temporary, Found, SeeOther."
  }
}

# Identity
variable "identity" {
  description = "Managed identity configuration for the application gateway"
  type = object({
    type         = string
    identity_ids = optional(list(string))
  })
  default = null

  validation {
    condition = var.identity == null || (
      contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity.type)
    )
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

# Diagnostic Settings
variable "enable_diagnostics" {
  description = "Enable diagnostic settings for the application gateway"
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
  default = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayPerformanceLog",
    "ApplicationGatewayFirewallLog"
  ]
}

variable "diagnostic_metric_categories" {
  description = "List of diagnostic metric categories to enable"
  type        = list(string)
  default     = ["AllMetrics"]
}
