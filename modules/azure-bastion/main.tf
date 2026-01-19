resource "azurerm_public_ip" "bastion" {
  count = var.create_public_ip ? 1 : 0

  name                = var.public_ip_name != null ? var.public_ip_name : "${var.name}-pip"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = var.zones

  tags = var.tags
}

resource "azurerm_bastion_host" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  # Optional features (require Standard SKU)
  copy_paste_enabled     = var.copy_paste_enabled
  file_copy_enabled      = var.file_copy_enabled
  ip_connect_enabled     = var.ip_connect_enabled
  shareable_link_enabled = var.shareable_link_enabled
  tunneling_enabled      = var.tunneling_enabled

  # Scale units (Standard SKU only, 2-50)
  scale_units = var.sku == "Standard" ? var.scale_units : 2

  ip_configuration {
    name                 = "bastion-ip-config"
    subnet_id            = var.subnet_id
    public_ip_address_id = var.create_public_ip ? azurerm_public_ip.bastion[0].id : var.public_ip_id
  }

  tags = var.tags
}
