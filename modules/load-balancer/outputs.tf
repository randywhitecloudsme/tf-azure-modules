output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = azurerm_lb.this.id
}

output "load_balancer_name" {
  description = "The name of the load balancer"
  value       = azurerm_lb.this.name
}

output "public_ip_address" {
  description = "The public IP address of the load balancer"
  value       = var.type == "public" ? azurerm_public_ip.this[0].ip_address : null
}

output "public_ip_id" {
  description = "The ID of the public IP address"
  value       = var.type == "public" ? azurerm_public_ip.this[0].id : null
}

output "frontend_ip_configurations" {
  description = "Frontend IP configuration details"
  value       = azurerm_lb.this.frontend_ip_configuration
}

output "backend_address_pool_ids" {
  description = "Map of backend address pool names to their IDs"
  value       = { for k, v in azurerm_lb_backend_address_pool.this : k => v.id }
}

output "probe_ids" {
  description = "Map of health probe names to their IDs"
  value       = { for k, v in azurerm_lb_probe.this : k => v.id }
}
