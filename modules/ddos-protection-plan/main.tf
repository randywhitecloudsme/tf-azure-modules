resource "azurerm_network_ddos_protection_plan" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}
