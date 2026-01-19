output "private_endpoint_id" {
  description = "The ID of the private endpoint"
  value       = module.private_endpoint.private_endpoint_id
}

output "private_endpoint_name" {
  description = "The name of the private endpoint"
  value       = module.private_endpoint.private_endpoint_name
}

output "private_ip_address" {
  description = "The private IP address of the private endpoint"
  value       = module.private_endpoint.private_ip_address
}

output "storage_account_id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.example.id
}

output "storage_account_primary_blob_endpoint" {
  description = "The primary blob endpoint of the storage account"
  value       = azurerm_storage_account.example.primary_blob_endpoint
}

output "private_dns_zone_id" {
  description = "The ID of the private DNS zone"
  value       = azurerm_private_dns_zone.blob.id
}

output "vnet_id" {
  description = "The ID of the virtual network"
  value       = azurerm_virtual_network.example.id
}
