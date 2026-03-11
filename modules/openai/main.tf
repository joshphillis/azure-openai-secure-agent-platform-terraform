locals {
  name = var.openai_name != null ?
    var.openai_name :
    "${var.project_name}-${var.environment}-openai"
}

resource "azurerm_cognitive_account" "this" {
  name                = local.name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.sku_name

  tags = {
    project     = var.project_name
    environment = var.environment
  }
}

# Model deployments
resource "azurerm_cognitive_deployment" "deployments" {
  for_each = {
    for d in var.deployments : d.name => d
  }

  name                 = each.value.name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    name    = each.value.model_name
    version = each.value.model_version
  }

  scale {
    type = each.value.scale_type
  }
}
