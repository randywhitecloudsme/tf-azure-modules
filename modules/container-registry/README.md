# Azure Container Registry Module

This module creates an Azure Container Registry (ACR).

## Usage

### Basic Configuration

```hcl
module "acr" {
  source = "../../"

  name                = "mycontainerregistry"
  resource_group_name = "my-rg"
  location            = "eastus"
  sku                 = "Standard"

  tags = {
    Environment = "Production"
  }
}
```

### Premium with Geo-replication

```hcl
module "acr" {
  source = "../../"

  name                = "mycontainerregistry"
  resource_group_name = "my-rg"
  location            = "eastus"
  sku                 = "Premium"

  georeplications = [
    {
      location                = "westus"
      zone_redundancy_enabled = true
    }
  ]

  network_rule_set = {
    default_action = "Deny"
    ip_rules       = ["203.0.113.0/24"]
  }

  retention_policy = {
    days    = 30
    enabled = true
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
| name | The name of the Container Registry | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| sku | The SKU name (Basic, Standard, Premium) | `string` | `"Standard"` | no |
| admin_enabled | Specifies whether the admin user is enabled | `bool` | `false` | no |
| public_network_access_enabled | Whether public network access is allowed | `bool` | `true` | no |
| georeplications | List of geo-replication configurations | `list(object)` | `[]` | no |
| network_rule_set | Network rule set configuration | `object` | `null` | no |
| retention_policy | Retention policy configuration | `object` | `null` | no |
| trust_policy_enabled | Whether trust policy is enabled | `bool` | `false` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Container Registry |
| name | The name of the Container Registry |
| login_server | The URL to log into the container registry |
| admin_username | The admin username (if enabled) |
| admin_password | The admin password (sensitive, if enabled) |

## Notes

- Geo-replication, network rules, retention policy, and trust policy are only available with Premium SKU
- Container Registry names must be globally unique and contain only alphanumeric characters
