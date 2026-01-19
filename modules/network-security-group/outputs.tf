output "nsg_id" {
  description = "The ID of the network security group"
  value       = azurerm_network_security_group.this.id
}

output "nsg_name" {
  description = "The name of the network security group"
  value       = azurerm_network_security_group.this.name
}

output "nsg_location" {
  description = "The location of the network security group"
  value       = azurerm_network_security_group.this.location
}

output "security_rule_ids" {
  description = "Map of security rule names to their IDs"
  value       = { for k, v in azurerm_network_security_rule.this : k => v.id }
}

output "flow_log_id" {
  description = "The ID of the flow log (if enabled)"
  value       = var.enable_flow_logs ? azurerm_network_watcher_flow_log.this[0].id : null
}
