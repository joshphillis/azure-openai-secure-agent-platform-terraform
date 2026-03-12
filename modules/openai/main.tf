locals {
  name = coalesce(
    var.openai_name,
    "aoai-${var.environment}-${substr(md5(var.project_name), 0, 6)}"
  )
}

data "azurerm_cognitive_account" "this" {
  name                = local.name
  resource_group_name = var.resource_group_name
}