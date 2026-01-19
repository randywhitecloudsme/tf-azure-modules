output "bastion_id" {
  description = "The ID of the Bastion host"
  value       = azurerm_bastion_host.this.id
}

output "bastion_name" {
  description = "The name of the Bastion host"
  value       = azurerm_bastion_host.this.name
}

output "bastion_dns_name" {
  description = "The FQDN for the Bastion host"
  value       = azurerm_bastion_host.this.dns_name
}

output "public_ip_id" {
  description = "The ID of the Bastion public IP"
  value       = var.create_public_ip ? azurerm_public_ip.bastion[0].id : var.public_ip_id
}

output "public_ip_address" {
  description = "The public IP address of the Bastion host"
  value       = var.create_public_ip ? azurerm_public_ip.bastion[0].ip_address : null
}
