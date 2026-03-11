output "vnet_id" {
  description = "ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "container_apps_subnet_id" {
  description = "ID of the delegated Container Apps subnet."
  value       = azurerm_subnet.containerapps.id
}

output "workload_subnet_id" {
  description = "ID of the optional workload subnet."
  value       = try(azurerm_subnet.workload[0].id, null)
}
