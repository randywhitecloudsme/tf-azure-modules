output "application_gateway_id" {
  description = "The ID of the application gateway"
  value       = azurerm_application_gateway.this.id
}

output "application_gateway_name" {
  description = "The name of the application gateway"
  value       = azurerm_application_gateway.this.name
}

output "public_ip_address" {
  description = "The public IP address of the application gateway"
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "public_ip_id" {
  description = "The ID of the public IP address"
  value       = var.create_public_ip ? azurerm_public_ip.this[0].id : null
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their IDs"
  value       = { for pool in azurerm_application_gateway.this.backend_address_pool : pool.name => pool.id }
}

output "frontend_ip_configuration" {
  description = "Frontend IP configuration details"
  value       = azurerm_application_gateway.this.frontend_ip_configuration
}

output "identity_principal_id" {
  description = "The principal ID of the system assigned identity"
  value       = try(azurerm_application_gateway.this.identity[0].principal_id, null)
}
