resource "azurerm_cognitive_account" "this" {
  name                = var.openai_name
  location            = var.location
  resource_group_name = var.resource_group_name
  kind                = "OpenAI"
  sku_name            = var.openai_sku
}

data "azurerm_cognitive_account" "this" {
  name                = azurerm_cognitive_account.this.name
  resource_group_name = var.resource_group_name

  depends_on = [
    azurerm_cognitive_account.this
  ]
}