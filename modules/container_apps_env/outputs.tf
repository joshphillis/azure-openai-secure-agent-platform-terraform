output "env_id" {
  description = "The ID of the Container Apps Environment."
  value       = azurerm_container_app_environment.this.id
}

output "env_name" {
  description = "The name of the Container Apps Environment."
  value       = azurerm_container_app_environment.this.name
}

output "default_domain" {
  description = "Default domain for the environment."
  value       = azurerm_container_app_environment.this.default_domain
}
