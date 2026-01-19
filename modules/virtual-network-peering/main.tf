# Virtual Network Peering - Source to Destination
resource "azurerm_virtual_network_peering" "source_to_destination" {
  name                      = var.name
  resource_group_name       = var.source_resource_group_name
  virtual_network_name      = var.source_virtual_network_name
  remote_virtual_network_id = var.destination_virtual_network_id

  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways

  triggers = var.triggers
}

# Virtual Network Peering - Destination to Source (bidirectional)
resource "azurerm_virtual_network_peering" "destination_to_source" {
  count = var.create_bidirectional_peering ? 1 : 0

  name                      = var.reverse_name
  resource_group_name       = var.destination_resource_group_name
  virtual_network_name      = var.destination_virtual_network_name
  remote_virtual_network_id = var.source_virtual_network_id

  allow_virtual_network_access = var.reverse_allow_virtual_network_access
  allow_forwarded_traffic      = var.reverse_allow_forwarded_traffic
  allow_gateway_transit        = var.reverse_allow_gateway_transit
  use_remote_gateways          = var.reverse_use_remote_gateways

  triggers = var.reverse_triggers
}
