resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "endpoints" {
  for_each = { for ep in var.endpoints : ep.name => ep }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  enabled                  = lookup(each.value, "enabled", true)

  tags = var.tags
}

resource "azurerm_cdn_frontdoor_origin_group" "groups" {
  for_each = { for og in var.origin_groups : og.name => og }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                        = lookup(each.value, "sample_size", 4)
    successful_samples_required        = lookup(each.value, "successful_samples_required", 3)
    additional_latency_in_milliseconds = lookup(each.value, "additional_latency_milliseconds", 50)
  }

  dynamic "health_probe" {
    for_each = lookup(each.value, "health_probe_enabled", true) ? [1] : []

    content {
      protocol            = lookup(each.value, "health_probe_protocol", "Https")
      interval_in_seconds = lookup(each.value, "health_probe_interval", 100)
      path                = lookup(each.value, "health_probe_path", "/")
      request_type        = lookup(each.value, "health_probe_request_type", "HEAD")
    }
  }

  session_affinity_enabled = lookup(each.value, "session_affinity_enabled", false)
}

resource "azurerm_cdn_frontdoor_origin" "origins" {
  for_each = { for origin in var.origins : "${origin.origin_group_name}-${origin.name}" => origin }

  name                          = each.value.name
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.groups[each.value.origin_group_name].id

  enabled                        = lookup(each.value, "enabled", true)
  host_name                      = each.value.host_name
  http_port                      = lookup(each.value, "http_port", 80)
  https_port                     = lookup(each.value, "https_port", 443)
  origin_host_header             = lookup(each.value, "origin_host_header", each.value.host_name)
  priority                       = lookup(each.value, "priority", 1)
  weight                         = lookup(each.value, "weight", 1000)
  certificate_name_check_enabled = lookup(each.value, "certificate_name_check_enabled", true)

  dynamic "private_link" {
    for_each = lookup(each.value, "private_link_target_id", null) != null ? [1] : []

    content {
      request_message        = lookup(each.value, "private_link_request_message", "Please approve this private link connection")
      target_type            = lookup(each.value, "private_link_target_type", null)
      location               = lookup(each.value, "private_link_location", null)
      private_link_target_id = each.value.private_link_target_id
    }
  }
}

resource "azurerm_cdn_frontdoor_route" "routes" {
  for_each = { for route in var.routes : route.name => route }

  name                          = each.value.name
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.endpoints[each.value.endpoint_name].id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.groups[each.value.origin_group_name].id
  cdn_frontdoor_origin_ids = [
    for origin_name in each.value.origin_names :
    azurerm_cdn_frontdoor_origin.origins["${each.value.origin_group_name}-${origin_name}"].id
  ]

  enabled                = lookup(each.value, "enabled", true)
  forwarding_protocol    = lookup(each.value, "forwarding_protocol", "HttpsOnly")
  https_redirect_enabled = lookup(each.value, "https_redirect_enabled", true)
  patterns_to_match      = lookup(each.value, "patterns_to_match", ["/*"])
  supported_protocols    = lookup(each.value, "supported_protocols", ["Http", "Https"])

  cdn_frontdoor_custom_domain_ids = lookup(each.value, "custom_domain_names", null) != null ? [
    for domain_name in each.value.custom_domain_names :
    azurerm_cdn_frontdoor_custom_domain.domains[domain_name].id
  ] : []

  link_to_default_domain = lookup(each.value, "link_to_default_domain", true)

  dynamic "cache" {
    for_each = lookup(each.value, "cache_enabled", false) ? [1] : []

    content {
      query_string_caching_behavior = lookup(each.value, "query_string_caching_behavior", "IgnoreQueryString")
      query_strings                 = lookup(each.value, "query_strings", null)
      compression_enabled           = lookup(each.value, "compression_enabled", true)
      content_types_to_compress     = lookup(each.value, "content_types_to_compress", null)
    }
  }

  cdn_frontdoor_rule_set_ids = lookup(each.value, "rule_set_names", null) != null ? [
    for rule_set_name in each.value.rule_set_names :
    azurerm_cdn_frontdoor_rule_set.rule_sets[rule_set_name].id
  ] : []
}

resource "azurerm_cdn_frontdoor_custom_domain" "domains" {
  for_each = { for domain in var.custom_domains : domain.name => domain }

  name                     = each.value.name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  host_name                = each.value.host_name

  dynamic "tls" {
    for_each = [1]

    content {
      certificate_type    = lookup(each.value, "certificate_type", "ManagedCertificate")
      minimum_tls_version = lookup(each.value, "minimum_tls_version", "TLS12")
    }
  }
}

resource "azurerm_cdn_frontdoor_rule_set" "rule_sets" {
  for_each = toset(var.rule_set_names)

  name                     = each.value
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
}

resource "azurerm_cdn_frontdoor_security_policy" "waf" {
  for_each = var.waf_policy_id != null ? toset([for ep in var.endpoints : ep.name]) : []

  name                     = "waf-policy-${each.value}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  security_policies {
    firewall {
      cdn_frontdoor_firewall_policy_id = var.waf_policy_id

      association {
        domain {
          cdn_frontdoor_domain_id = azurerm_cdn_frontdoor_endpoint.endpoints[each.value].id
        }

        patterns_to_match = ["/*"]
      }
    }
  }
}
