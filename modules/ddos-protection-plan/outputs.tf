output "ddos_protection_plan_id" {
  description = "The ID of the DDoS Protection Plan"
  value       = azurerm_network_ddos_protection_plan.this.id
}

output "ddos_protection_plan_name" {
  description = "The name of the DDoS Protection Plan"
  value       = azurerm_network_ddos_protection_plan.this.name
}

output "virtual_network_ids" {
  description = "List of virtual network IDs protected by this plan"
  value       = azurerm_network_ddos_protection_plan.this.virtual_network_ids
}
