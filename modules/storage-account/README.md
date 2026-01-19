# Azure Storage Account Module

This module creates an Azure Storage Account with optional containers.

## Usage

```hcl
module "storage" {
  source = "../../"

  name                = "mystorageaccount"
  resource_group_name = "my-rg"
  location            = "eastus"
  
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  blob_properties = {
    versioning_enabled = true
    delete_retention_policy = {
      days = 7
    }
  }
  
  containers = {
    data = {
      name                  = "data"
      container_access_type = "private"
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
| name | The name of the storage account | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| location | The Azure region where the storage account will be created | `string` | n/a | yes |
| account_tier | Defines the Tier to use for this storage account | `string` | `"Standard"` | no |
| account_replication_type | Defines the type of replication to use | `string` | `"LRS"` | no |
| account_kind | Defines the Kind of account | `string` | `"StorageV2"` | no |
| access_tier | Defines the access tier | `string` | `"Hot"` | no |
| enable_https_traffic_only | Boolean flag which forces HTTPS | `bool` | `true` | no |
| min_tls_version | The minimum supported TLS version | `string` | `"TLS1_2"` | no |
| allow_nested_items_to_be_public | Allow nested items to be public | `bool` | `false` | no |
| blob_properties | Blob properties configuration | `object` | `null` | no |
| network_rules | Network rules configuration | `object` | `null` | no |
| containers | Map of storage containers to create | `map(object)` | `{}` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the storage account |
| name | The name of the storage account |
| primary_blob_endpoint | The endpoint URL for blob storage |
| primary_access_key | The primary access key (sensitive) |
| primary_connection_string | The connection string (sensitive) |
| container_ids | Map of container names to their IDs |
