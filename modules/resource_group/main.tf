resource "azurerm_resource_group" "this" {
  name     = "${var.project_name}-${var.environment}-rg"
  location = var.location

  tags = merge(
    {
      project     = var.project_name
      environment = var.environment
    },
    var.tags
  )
}
