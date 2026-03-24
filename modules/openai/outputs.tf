output "id" {
  value = azurerm_cognitive_account.this.id
}

output "endpoint" {
  value = azurerm_cognitive_account.this.endpoint
}

output "primary_key" {
  value     = azurerm_cognitive_account.this.primary_access_key
  sensitive = true
}

output "name" {
  value = azurerm_cognitive_account.this.name
}

output "private_ip_address" {
  description = "Private IP of the OpenAI private endpoint."
  value       = azurerm_private_endpoint.openai.private_service_connection[0].private_ip_address
}
