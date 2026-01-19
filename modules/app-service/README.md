# Azure App Service Module

This module creates an Azure App Service with a Service Plan.

## Usage

### Linux App Service with Node.js

```hcl
module "app_service" {
  source = "../../"

  service_plan_name   = "my-service-plan"
  app_name            = "my-app-service"
  location            = "eastus"
  resource_group_name = "my-rg"
  
  os_type  = "Linux"
  sku_name = "B1"
  
  application_stack = {
    node_version = "18-lts"
  }
  
  app_settings = {
    "WEBSITE_NODE_DEFAULT_VERSION" = "~18"
    "NODE_ENV"                     = "production"
  }

  tags = {
    Environment = "Production"
  }
}
```

### Windows App Service with .NET

```hcl
module "app_service" {
  source = "../../"

  service_plan_name   = "my-service-plan"
  app_name            = "my-dotnet-app"
  location            = "eastus"
  resource_group_name = "my-rg"
  
  os_type  = "Windows"
  sku_name = "S1"
  
  application_stack = {
    current_stack  = "dotnet"
    dotnet_version = "v7.0"
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
| service_plan_name | The name of the Service Plan | `string` | n/a | yes |
| app_name | The name of the App Service | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| os_type | The OS type (Linux or Windows) | `string` | `"Linux"` | no |
| sku_name | The SKU for the Service Plan | `string` | `"B1"` | no |
| always_on | Should the app be loaded at all times? | `bool` | `true` | no |
| ftps_state | State of FTP / FTPS service | `string` | `"FtpsOnly"` | no |
| http2_enabled | Should HTTP2 be enabled? | `bool` | `true` | no |
| minimum_tls_version | The minimum supported TLS version | `string` | `"1.2"` | no |
| application_stack | Application stack configuration | `map(string)` | `null` | no |
| app_settings | Map of app settings | `map(string)` | `{}` | no |
| connection_strings | List of connection strings | `list(object)` | `[]` | no |
| https_only | Should the app be HTTPS only? | `bool` | `true` | no |
| tags | A mapping of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| service_plan_id | The ID of the Service Plan |
| service_plan_name | The name of the Service Plan |
| app_service_id | The ID of the App Service |
| app_service_name | The name of the App Service |
| default_hostname | The default hostname |
| outbound_ip_addresses | Outbound IP addresses |
