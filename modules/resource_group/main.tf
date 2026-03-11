variable "project_name" {
  type = string
}

variable "location" {
  type = string
}

variable "environment" {
  type = string
}

resource "azurerm_resource_group" "this" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

output "name" {
  value = azurerm_resource_group.this.name
}

output "id" {
  value = azurerm_resource_group.this.id
}
