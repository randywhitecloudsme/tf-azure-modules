output "traffic_manager_fqdn" {
  description = "The FQDN of the Traffic Manager profile"
  value       = module.traffic_manager.fqdn
}

output "traffic_manager_id" {
  description = "The ID of the Traffic Manager profile"
  value       = module.traffic_manager.traffic_manager_profile_id
}

output "primary_public_ip" {
  description = "The primary public IP address"
  value       = azurerm_public_ip.primary.ip_address
}

output "secondary_public_ip" {
  description = "The secondary public IP address"
  value       = azurerm_public_ip.secondary.ip_address
}

output "access_url" {
  description = "URL to access via Traffic Manager"
  value       = "http://${module.traffic_manager.fqdn}"
}
