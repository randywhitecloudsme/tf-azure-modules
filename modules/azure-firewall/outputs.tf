output "firewall_id" {
  description = "The ID of the Azure Firewall"
  value       = azurerm_firewall.this.id
}

output "firewall_name" {
  description = "The name of the Azure Firewall"
  value       = azurerm_firewall.this.name
}

output "firewall_private_ip" {
  description = "The private IP address of the firewall"
  value       = azurerm_firewall.this.ip_configuration[0].private_ip_address
}

output "firewall_public_ip" {
  description = "The public IP address of the firewall"
  value       = var.create_public_ip ? azurerm_public_ip.this[0].ip_address : null
}

output "firewall_policy_id" {
  description = "The ID of the firewall policy"
  value       = var.create_firewall_policy ? azurerm_firewall_policy.this[0].id : var.firewall_policy_id
}

output "rule_collection_group_ids" {
  description = "Map of rule collection group names to their IDs"
  value       = { for k, v in azurerm_firewall_policy_rule_collection_group.this : k => v.id }
}
