resource "azurerm_virtual_network" "this" {
  name                = "${var.project_name}-${var.environment}-vnet"
  address_space       = [var.vnet_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "containerapps" {
  name                 = "${var.project_name}-${var.environment}-snet-containerapps"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_cidrs.containerapps]

  delegation {
    name = "containerapps-delegation"

    service_delegation {
      name = "Microsoft.Web/containerApps"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Optional workload subnet (if you want one)
resource "azurerm_subnet" "workload" {
  count                = var.subnet_cidrs.workload != null ? 1 : 0
  name                 = "${var.project_name}-${var.environment}-snet-workload"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [var.subnet_cidrs.workload]
}
