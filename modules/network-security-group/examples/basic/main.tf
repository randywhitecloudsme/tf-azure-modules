module "nsg_basic" {
  source = "../.."

  name                = "nsg-example-basic"
  location            = var.location
  resource_group_name = var.resource_group_name

  security_rules = {
    allow_ssh = {
      name                       = "AllowSSH"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = "*"
      destination_address_prefix = "*"
      description                = "Allow SSH"
    }
    allow_https = {
      name                       = "AllowHTTPS"
      priority                   = 110
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "443"
      source_address_prefix      = "Internet"
      destination_address_prefix = "VirtualNetwork"
      description                = "Allow HTTPS from Internet"
    }
  }

  tags = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
