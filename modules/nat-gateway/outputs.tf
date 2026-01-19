output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = azurerm_nat_gateway.this.id
}

output "nat_gateway_name" {
  description = "The name of the NAT Gateway"
  value       = azurerm_nat_gateway.this.name
}

output "public_ip_addresses" {
  description = "List of public IP addresses associated with the NAT Gateway"
  value       = [for pip in azurerm_public_ip.this : pip.ip_address]
}

output "public_ip_ids" {
  description = "List of public IP IDs associated with the NAT Gateway"
  value       = [for pip in azurerm_public_ip.this : pip.id]
}

output "public_ip_prefix_id" {
  description = "The ID of the public IP prefix (if created)"
  value       = var.create_public_ip_prefix ? azurerm_public_ip_prefix.this[0].id : null
}

output "public_ip_prefix" {
  description = "The IP prefix (if created)"
  value       = var.create_public_ip_prefix ? azurerm_public_ip_prefix.this[0].ip_prefix : null
}
