output "hub_vnet_id" {
  description = "The ID of the hub virtual network"
  value       = azurerm_virtual_network.hub.id
}

output "spoke_vnet_id" {
  description = "The ID of the spoke virtual network"
  value       = azurerm_virtual_network.spoke.id
}

output "source_to_destination_peering_id" {
  description = "The ID of the hub to spoke peering"
  value       = module.vnet_peering.source_to_destination_peering_id
}

output "destination_to_source_peering_id" {
  description = "The ID of the spoke to hub peering"
  value       = module.vnet_peering.destination_to_source_peering_id
}

output "source_to_destination_peering_name" {
  description = "The name of the hub to spoke peering"
  value       = module.vnet_peering.source_to_destination_peering_name
}

output "destination_to_source_peering_name" {
  description = "The name of the spoke to hub peering"
  value       = module.vnet_peering.destination_to_source_peering_name
}
