output "route_table_id" {
  description = "The ID of the route table"
  value       = azurerm_route_table.this.id
}

output "route_table_name" {
  description = "The name of the route table"
  value       = azurerm_route_table.this.name
}

output "route_ids" {
  description = "Map of route names to their IDs"
  value       = { for k, v in azurerm_route.routes : k => v.id }
}

output "subnet_associations" {
  description = "Map of subnet IDs to their route table association IDs"
  value       = { for k, v in azurerm_subnet_route_table_association.associations : k => v.id }
}
