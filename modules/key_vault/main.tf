locals {
  name = var.kv_name != null ?
    var.kv_name :
    "${var.project_name}-${var.environment}-kv"
}

resource "azurerm_key_vault" "this" {
  name                        = local.name
  location                    = var.location
  resource_group_name         = var.resource_group_name
  tenant_id                   = var.tenant_id
  sku_name                    = "standard"
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# Identity for apps to retrieve secrets
resource "azurerm_user_assigned_identity" "app_identity" {
  name                = "${local.name}-id"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# Allow identity to read secrets
resource "azurerm_key_vault_access_policy" "app_policy" {
  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = var.tenant_id
  object_id    = azurerm_user_assigned_identity.app_identity.principal_id

  secret_permissions = [
    "Get",
    "List"
  ]
}
