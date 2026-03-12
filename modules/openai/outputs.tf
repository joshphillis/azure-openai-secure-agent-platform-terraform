output "id" {
  value = data.azurerm_cognitive_account.this.id
}

output "endpoint" {
  value = data.azurerm_cognitive_account.this.endpoint
}

output "primary_key" {
  value     = data.azurerm_cognitive_account.this.primary_access_key
  sensitive = true
}

output "name" {
  value = data.azurerm_cognitive_account.this.name
}