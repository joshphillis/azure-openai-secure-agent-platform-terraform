locals {
  name = var.acr_name != null ?
    var.acr_name :
    "${var.project_name}${var.environment}acr"
}

resource "azurerm_container_registry" "this" {
  name                = local.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = false

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# Managed identity for Container Apps pull
resource "azurerm_user_assigned_identity" "acr_pull" {
  name                = "${local.name}-pull-id"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# Assign AcrPull role to the identity
resource "azurerm_role_assignment" "acr_pull_assignment" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.acr_pull.principal_id
}
