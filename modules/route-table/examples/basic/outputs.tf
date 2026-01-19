output "route_table_id" {
  description = "The ID of the route table"
  value       = module.route_table.route_table_id
}

output "route_table_name" {
  description = "The name of the route table"
  value       = module.route_table.route_table_name
}

output "route_ids" {
  description = "Map of route names to their IDs"
  value       = module.route_table.route_ids
}

output "subnet_id" {
  description = "The ID of the subnet"
  value       = azurerm_subnet.example.id
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}
