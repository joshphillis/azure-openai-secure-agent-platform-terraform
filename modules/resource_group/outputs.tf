output "name" {
  description = "The name of the resource group."
  value       = azurerm_resource_group.this.name
}

output "id" {
  description = "The ID of the resource group."
  value       = azurerm_resource_group.this.id
}
