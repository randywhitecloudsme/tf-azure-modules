output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone"
  value       = azurerm_private_dns_zone.this.id
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS Zone"
  value       = azurerm_private_dns_zone.this.name
}

output "private_dns_zone_number_of_record_sets" {
  description = "The current number of record sets in the Private DNS Zone"
  value       = azurerm_private_dns_zone.this.number_of_record_sets
}

output "private_dns_zone_max_number_of_record_sets" {
  description = "The maximum number of record sets that can be created in the Private DNS Zone"
  value       = azurerm_private_dns_zone.this.max_number_of_record_sets
}

output "virtual_network_link_ids" {
  description = "Map of virtual network link names to their IDs"
  value       = { for k, v in azurerm_private_dns_zone_virtual_network_link.this : k => v.id }
}

output "a_record_ids" {
  description = "Map of A record names to their IDs"
  value       = { for k, v in azurerm_private_dns_a_record.this : k => v.id }
}

output "cname_record_ids" {
  description = "Map of CNAME record names to their IDs"
  value       = { for k, v in azurerm_private_dns_cname_record.this : k => v.id }
}
