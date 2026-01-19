output "traffic_manager_profile_id" {
  description = "The ID of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.this.id
}

output "traffic_manager_profile_name" {
  description = "The name of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.this.name
}

output "fqdn" {
  description = "The FQDN of the Traffic Manager profile"
  value       = azurerm_traffic_manager_profile.this.fqdn
}

output "azure_endpoint_ids" {
  description = "Map of Azure endpoint names to their IDs"
  value       = { for k, v in azurerm_traffic_manager_azure_endpoint.azure_endpoints : k => v.id }
}

output "external_endpoint_ids" {
  description = "Map of external endpoint names to their IDs"
  value       = { for k, v in azurerm_traffic_manager_external_endpoint.external_endpoints : k => v.id }
}

output "nested_endpoint_ids" {
  description = "Map of nested endpoint names to their IDs"
  value       = { for k, v in azurerm_traffic_manager_nested_endpoint.nested_endpoints : k => v.id }
}
