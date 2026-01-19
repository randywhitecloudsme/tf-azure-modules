output "id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.this.id
}

output "name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.this.name
}

output "vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.this.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value       = { for k, v in azurerm_key_vault_secret.this : k => v.id }
}

output "private_endpoint_id" {
  description = "The ID of the private endpoint (if created)"
  value       = var.enable_private_endpoint ? azurerm_private_endpoint.this[0].id : null
}
