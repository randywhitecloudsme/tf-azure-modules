resource "azurerm_private_endpoint" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  private_service_connection {
    name                           = "${var.name}-connection"
    private_connection_resource_id = var.private_connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = var.subresource_names
    request_message                = var.is_manual_connection ? var.request_message : null
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_ids != null ? [1] : []

    content {
      name                 = var.private_dns_zone_group_name != null ? var.private_dns_zone_group_name : "${var.name}-dns-group"
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = var.ip_configurations

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = ip_configuration.value.subresource_name
      member_name        = ip_configuration.value.member_name
    }
  }

  tags = var.tags
}
