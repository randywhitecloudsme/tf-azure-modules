output "source_to_destination_peering_id" {
  description = "The ID of the source to destination peering"
  value       = azurerm_virtual_network_peering.source_to_destination.id
}

output "source_to_destination_peering_name" {
  description = "The name of the source to destination peering"
  value       = azurerm_virtual_network_peering.source_to_destination.name
}

output "destination_to_source_peering_id" {
  description = "The ID of the destination to source peering"
  value       = var.create_bidirectional_peering ? azurerm_virtual_network_peering.destination_to_source[0].id : null
}

output "destination_to_source_peering_name" {
  description = "The name of the destination to source peering"
  value       = var.create_bidirectional_peering ? azurerm_virtual_network_peering.destination_to_source[0].name : null
}
