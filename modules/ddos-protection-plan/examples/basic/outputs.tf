output "ddos_protection_plan_id" {
  description = "The ID of the DDoS Protection Plan"
  value       = module.ddos_protection.ddos_protection_plan_id
}

output "ddos_protection_plan_name" {
  description = "The name of the DDoS Protection Plan"
  value       = module.ddos_protection.ddos_protection_plan_name
}

output "protected_vnet_id" {
  description = "The ID of the protected virtual network"
  value       = azurerm_virtual_network.example.id
}

output "protected_vnet_name" {
  description = "The name of the protected virtual network"
  value       = azurerm_virtual_network.example.name
}
