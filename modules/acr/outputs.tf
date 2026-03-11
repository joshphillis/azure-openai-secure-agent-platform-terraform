output "login_server" {
  description = "The ACR login server (e.g., secureagentdevacr.azurecr.io)."
  value       = azurerm_container_registry.this.login_server
}

output "registry_id" {
  description = "The ID of the ACR."
  value       = azurerm_container_registry.this.id
}

output "identity_id" {
  description = "The ID of the managed identity used for ACR pulls."
  value       = azurerm_user_assigned_identity.acr_pull.id
}

output "identity_principal_id" {
  description = "The principal ID of the managed identity."
  value       = azurerm_user_assigned_identity.acr_pull.principal_id
}
