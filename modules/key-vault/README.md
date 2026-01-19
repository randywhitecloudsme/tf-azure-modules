# Azure Key Vault Module

This module creates an Azure Key Vault with access policies and secrets.

## Usage

```hcl
data "azurerm_client_config" "current" {}

module "key_vault" {
  source = "../../"

  name                = "my-keyvault"
  location            = "eastus"
  resource_group_name = "my-rg"
  
  access_policies = {
    current_user = {
      object_id = data.azurerm_client_config.current.object_id
      secret_permissions = ["Get", "List", "Set", "Delete"]
    }
  }
  
  secrets = {
    db_password = {
      name  = "database-password"
      value = "super-secret-password"
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
| name | The name of the key vault | `string` | n/a | yes |
| location | The Azure region where the key vault will be created | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| tenant_id | The Azure Active Directory tenant ID | `string` | `null` | no |
| sku_name | The Name of the SKU used for this Key Vault | `string` | `"standard"` | no |
| soft_delete_retention_days | The number of days that items should be retained | `number` | `90` | no |
| purge_protection_enabled | Is Purge Protection enabled? | `bool` | `false` | no |
| enabled_for_deployment | Boolean flag for VM certificate retrieval | `bool` | `false` | no |
| enabled_for_disk_encryption | Boolean flag for disk encryption | `bool` | `false` | no |
| enabled_for_template_deployment | Boolean flag for ARM secret retrieval | `bool` | `false` | no |
| network_acls | Network ACLs configuration | `object` | `null` | no |
| access_policies | Map of access policies to create | `map(object)` | `{}` | no |
| secrets | Map of secrets to create | `map(object)` | `{}` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Key Vault |
| name | The name of the Key Vault |
| vault_uri | The URI of the Key Vault |
| secret_ids | Map of secret names to their IDs |
