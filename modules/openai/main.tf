locals {
  name = coalesce(var.openai_name, "${var.project_name}-${var.environment}-aoai")
}

# -----------------------------------------------------------
# Azure OpenAI Cognitive Account
# -----------------------------------------------------------
resource "azurerm_cognitive_account" "this" {
  name                          = local.name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  kind                          = "OpenAI"
  sku_name                      = var.openai_sku
  custom_subdomain_name         = local.name      # required for private endpoint
  public_network_access_enabled = false            # private-only access

  identity {
    type = "SystemAssigned"
  }

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# -----------------------------------------------------------
# Private DNS Zone
# Must be exactly "privatelink.openai.azure.com"
# -----------------------------------------------------------
resource "azurerm_private_dns_zone" "openai" {
  name                = "privatelink.openai.azure.com"
  resource_group_name = var.resource_group_name

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# -----------------------------------------------------------
# VNet Link — links DNS zone to your VNet
# WITHOUT this, Container Apps can't resolve the endpoint!
# -----------------------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "openai" {
  name                  = "${local.name}-dns-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.openai.name
  virtual_network_id    = var.vnet_id
  registration_enabled  = false

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# -----------------------------------------------------------
# Private Endpoint — attaches OpenAI to your workload subnet
# -----------------------------------------------------------
resource "azurerm_private_endpoint" "openai" {
  name                = "${local.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${local.name}-psc"
    private_connection_resource_id = azurerm_cognitive_account.this.id
    subresource_names              = ["account"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "openai-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.openai.id]
  }

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}
