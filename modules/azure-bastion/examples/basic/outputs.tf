output "bastion_id" {
  description = "The ID of the Bastion host"
  value       = module.bastion.bastion_id
}

output "bastion_name" {
  description = "The name of the Bastion host"
  value       = module.bastion.bastion_name
}

output "bastion_dns_name" {
  description = "The FQDN of the Bastion host"
  value       = module.bastion.bastion_dns_name
}

output "public_ip_address" {
  description = "The public IP address of the Bastion host"
  value       = module.bastion.public_ip_address
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}

output "bastion_subnet_id" {
  description = "The ID of the AzureBastionSubnet"
  value       = azurerm_subnet.bastion.id
}
