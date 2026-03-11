output "id" {
  description = "The ID of the Azure OpenAI resource."
  value       = azurerm_cognitive_account.this.id
}

output "endpoint" {
  description = "The endpoint URL for Azure OpenAI."
  value       = azurerm_cognitive_account.this.endpoint
}

output "deployments" {
  description = "Map of deployment names to their IDs."
  value       = {
    for k, v in azurerm_cognitive_deployment.deployments :
    k => v.id
  }
}
