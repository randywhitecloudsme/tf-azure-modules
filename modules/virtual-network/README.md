# Azure Virtual Network Module

This module creates an Azure Virtual Network with subnets and network security groups.

## Usage

```hcl
module "vnet" {
  source = "../../"

  name                = "my-vnet"
  location            = "eastus"
  resource_group_name = "my-rg"
  address_space       = ["10.0.0.0/16"]

  subnets = {
    subnet1 = {
      name             = "subnet-1"
      address_prefixes = ["10.0.1.0/24"]
    }
    subnet2 = {
      name             = "subnet-2"
      address_prefixes = ["10.0.2.0/24"]
    }
  }

  network_security_groups = {
    nsg1 = {
      name = "nsg-1"
      security_rules = [
        {
          name                       = "AllowHTTP"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "80"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
        }
      ]
    }
  }

  subnet_nsg_associations = {
    assoc1 = {
      subnet_key = "subnet1"
      nsg_key    = "nsg1"
    }
  }

  tags = {
    Environment = "Production"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | The name of the virtual network | `string` | n/a | yes |
| location | The Azure region where the virtual network will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| address_space | The address space for the virtual network | `list(string)` | n/a | yes |
| dns_servers | List of DNS servers for the virtual network | `list(string)` | `[]` | no |
| subnets | Map of subnets to create | `map(object)` | `{}` | no |
| network_security_groups | Map of network security groups to create | `map(object)` | `{}` | no |
| subnet_nsg_associations | Map of subnet to NSG associations | `map(object)` | `{}` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| vnet_id | The ID of the virtual network |
| vnet_name | The name of the virtual network |
| vnet_address_space | The address space of the virtual network |
| subnet_ids | Map of subnet names to their IDs |
| nsg_ids | Map of NSG names to their IDs |
