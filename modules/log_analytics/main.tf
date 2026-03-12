locals {
  name = coalesce(var.workspace_name, "${var.project_name}-${var.environment}-law")
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
