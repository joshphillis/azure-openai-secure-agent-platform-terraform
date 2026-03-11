output "app_names" {
  description = "Names of all deployed container apps."
  value       = [for k, v in azurerm_container_app.apps : v.name]
}

output "app_ids" {
  description = "IDs of all deployed container apps."
  value       = { for k, v in azurerm_container_app.apps : k => v.id }
}

output "fqdn_map" {
  description = "Map of app names to their FQDNs."
  value       = { for k, v in azurerm_container_app.apps : k => v.latest_revision_fqdn }
}
