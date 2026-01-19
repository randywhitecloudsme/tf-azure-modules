output "id" {
  description = "The ID of the storage account"
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "The name of the storage account"
  value       = azurerm_storage_account.this.name
}

output "primary_blob_endpoint" {
  description = "The endpoint URL for blob storage in the primary location"
  value       = azurerm_storage_account.this.primary_blob_endpoint
}

output "primary_access_key" {
  description = "The primary access key for the storage account"
  value       = azurerm_storage_account.this.primary_access_key
  sensitive   = true
}

output "primary_connection_string" {
  description = "The connection string associated with the primary location"
  value       = azurerm_storage_account.this.primary_connection_string
  sensitive   = true
}

output "container_ids" {
  description = "Map of container names to their IDs"
  value       = { for k, v in azurerm_storage_container.this : k => v.id }
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.blob[0].id : null
}

output "identity_principal_id" {
  description = "The Principal ID of the system-assigned managed identity"
  value       = var.enable_system_assigned_identity ? azurerm_storage_account.this.identity[0].principal_id : null
}
