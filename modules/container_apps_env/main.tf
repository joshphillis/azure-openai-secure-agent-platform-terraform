locals {
  name = "${var.project_name}-${var.environment}-cae"
}

resource "azurerm_container_app_environment" "this" {
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name

  log_analytics_workspace_id = var.log_analytics_id
  infrastructure_subnet_id   = var.delegated_subnet_id

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}