output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.this.vault_uri
}

output "identity_id" {
  description = "The ID of the managed identity for apps."
  value       = azurerm_user_assigned_identity.app_identity.id
}

output "identity_principal_id" {
  description = "The principal ID of the managed identity."
  value       = azurerm_user_assigned_identity.app_identity.principal_id
}
