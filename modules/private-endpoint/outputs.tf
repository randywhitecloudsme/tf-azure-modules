output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = azurerm_private_endpoint.this.id
}

output "private_endpoint_name" {
  description = "The name of the private endpoint"
  value       = azurerm_private_endpoint.this.name
}

output "private_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = azurerm_private_endpoint.this.private_service_connection[0].private_ip_address
}

output "network_interface_id" {
  description = "The ID of the network interface associated with the private endpoint"
  value       = azurerm_private_endpoint.this.network_interface[0].id
}

output "custom_dns_configs" {
  description = "List of custom DNS configurations"
  value       = azurerm_private_endpoint.this.custom_dns_configs
}
