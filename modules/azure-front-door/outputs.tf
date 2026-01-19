output "front_door_id" {
  description = "The ID of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.this.id
}

output "front_door_name" {
  description = "The name of the Front Door profile"
  value       = azurerm_cdn_frontdoor_profile.this.name
}

output "endpoint_ids" {
  description = "Map of endpoint names to their IDs"
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.endpoints : k => v.id }
}

output "endpoint_host_names" {
  description = "Map of endpoint names to their host names"
  value       = { for k, v in azurerm_cdn_frontdoor_endpoint.endpoints : k => v.host_name }
}

output "origin_group_ids" {
  description = "Map of origin group names to their IDs"
  value       = { for k, v in azurerm_cdn_frontdoor_origin_group.groups : k => v.id }
}

output "origin_ids" {
  description = "Map of origin keys to their IDs"
  value       = { for k, v in azurerm_cdn_frontdoor_origin.origins : k => v.id }
}

output "route_ids" {
  description = "Map of route names to their IDs"
  value       = { for k, v in azurerm_cdn_frontdoor_route.routes : k => v.id }
}

output "custom_domain_ids" {
  description = "Map of custom domain names to their IDs"
  value       = { for k, v in azurerm_cdn_frontdoor_custom_domain.domains : k => v.id }
}
