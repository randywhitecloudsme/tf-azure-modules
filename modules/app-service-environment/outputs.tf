output "id" {
  description = "The ID of the App Service Environment"
  value       = azurerm_app_service_environment_v3.this.id
}

output "name" {
  description = "The name of the App Service Environment"
  value       = azurerm_app_service_environment_v3.this.name
}

output "location" {
  description = "The location of the App Service Environment"
  value       = azurerm_app_service_environment_v3.this.location
}

output "dns_suffix" {
  description = "The DNS suffix for apps in the App Service Environment"
  value       = azurerm_app_service_environment_v3.this.dns_suffix
}

output "internal_inbound_ip_addresses" {
  description = "The internal inbound IP addresses of the App Service Environment"
  value       = azurerm_app_service_environment_v3.this.internal_inbound_ip_addresses
}

output "external_inbound_ip_addresses" {
  description = "The external inbound IP addresses of the App Service Environment"
  value       = azurerm_app_service_environment_v3.this.external_inbound_ip_addresses
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone (if created)"
  value       = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? azurerm_private_dns_zone.ase[0].id : null
}

output "private_dns_zone_name" {
  description = "The name of the private DNS zone (if created)"
  value       = var.internal_load_balancing_mode != "None" && var.create_private_dns_zone ? azurerm_private_dns_zone.ase[0].name : null
}
