output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.this.id
}

output "vpn_gateway_name" {
  description = "The name of the VPN Gateway"
  value       = azurerm_virtual_network_gateway.this.name
}

output "public_ip_addresses" {
  description = "List of public IP addresses"
  value       = [for pip in azurerm_public_ip.this : pip.ip_address]
}

output "public_ip_ids" {
  description = "List of public IP IDs"
  value       = [for pip in azurerm_public_ip.this : pip.id]
}

output "bgp_settings" {
  description = "BGP settings of the VPN Gateway"
  value       = try(azurerm_virtual_network_gateway.this.bgp_settings, null)
}

output "local_network_gateway_ids" {
  description = "Map of local network gateway names to their IDs"
  value       = { for k, v in azurerm_local_network_gateway.this : k => v.id }
}

output "site_to_site_connection_ids" {
  description = "Map of Site-to-Site connection names to their IDs"
  value       = { for k, v in azurerm_virtual_network_gateway_connection.site_to_site : k => v.id }
}

output "vnet_to_vnet_connection_ids" {
  description = "Map of VNet-to-VNet connection names to their IDs"
  value       = { for k, v in azurerm_virtual_network_gateway_connection.vnet_to_vnet : k => v.id }
}
