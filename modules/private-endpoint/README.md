# Azure Private Endpoint Module

Production-ready Terraform module for creating and managing Azure Private Endpoints for secure, private access to Azure PaaS services.

## Features

- ✅ Support for all Azure PaaS services
- ✅ Automatic and manual connection approval
- ✅ Private DNS zone integration
- ✅ Custom IP configurations
- ✅ Multiple subresource support
- ✅ Network security isolation
- ✅ Production-ready defaults

## Usage

### Storage Account (Blob) Private Endpoint

```hcl
module "private_endpoint_blob" {
  source = "../../modules/private-endpoint"

  name                = "pe-storage-blob"
  location            = "eastus"
  resource_group_name = "rg-networking"

  # Subnet where private endpoint will be created
  subnet_id = azurerm_subnet.private_endpoints.id

  # Storage account to connect to
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["blob"]

  # Private DNS integration
  private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]

  tags = {
    Environment = "Production"
    Service     = "Storage"
  }
}
```

### SQL Database Private Endpoint

```hcl
module "private_endpoint_sql" {
  source = "../../modules/private-endpoint"

  name                = "pe-sql-server"
  location            = "eastus"
  resource_group_name = "rg-networking"

  subnet_id = azurerm_subnet.private_endpoints.id

  # SQL Server connection
  private_connection_resource_id = azurerm_mssql_server.example.id
  subresource_names              = ["sqlServer"]

  # DNS integration
  private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]

  tags = {
    Environment = "Production"
    Service     = "SQL"
  }
}
```

### Key Vault Private Endpoint

```hcl
module "private_endpoint_keyvault" {
  source = "../../modules/private-endpoint"

  name                = "pe-keyvault"
  location            = "eastus"
  resource_group_name = "rg-networking"

  subnet_id = azurerm_subnet.private_endpoints.id

  # Key Vault connection
  private_connection_resource_id = azurerm_key_vault.example.id
  subresource_names              = ["vault"]

  private_dns_zone_ids = [azurerm_private_dns_zone.keyvault.id]

  tags = {
    Environment = "Production"
    Service     = "KeyVault"
  }
}
```

### Manual Approval Connection

```hcl
module "private_endpoint_manual" {
  source = "../../modules/private-endpoint"

  name                = "pe-external-service"
  location            = "eastus"
  resource_group_name = "rg-networking"

  subnet_id = azurerm_subnet.private_endpoints.id

  private_connection_resource_id = var.external_service_id
  subresource_names              = ["sites"]

  # Manual approval required
  is_manual_connection = true
  request_message      = "Requesting access for production workload"

  tags = {
    Environment = "Production"
  }
}
```

### Multiple Storage Subresources

```hcl
# Private endpoint for blob storage
module "pe_blob" {
  source = "../../modules/private-endpoint"

  name                           = "pe-storage-blob"
  location                       = "eastus"
  resource_group_name            = "rg-networking"
  subnet_id                      = azurerm_subnet.pe.id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["blob"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.blob.id]
}

# Separate private endpoint for file storage
module "pe_file" {
  source = "../../modules/private-endpoint"

  name                           = "pe-storage-file"
  location                       = "eastus"
  resource_group_name            = "rg-networking"
  subnet_id                      = azurerm_subnet.pe.id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["file"]
  private_dns_zone_ids           = [azurerm_private_dns_zone.file.id]
}
```

### Complete Example with Private DNS

```hcl
# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-private"
  location            = "eastus"
  resource_group_name = "rg-networking"
  address_space       = ["10.0.0.0/16"]
}

# Subnet for private endpoints
resource "azurerm_subnet" "pe" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = "rg-networking"
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "storageacctexample"
  resource_group_name      = "rg-storage"
  location                 = "eastus"
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # Disable public access
  public_network_access_enabled = false
}

# Private DNS Zone
resource "azurerm_private_dns_zone" "blob" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-networking"
}

# Link DNS Zone to VNet
resource "azurerm_private_dns_zone_virtual_network_link" "blob" {
  name                  = "link-blob-dns"
  resource_group_name   = "rg-networking"
  private_dns_zone_name = azurerm_private_dns_zone.blob.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# Private Endpoint
module "private_endpoint" {
  source = "../../modules/private-endpoint"

  name                = "pe-storage-blob"
  location            = "eastus"
  resource_group_name = "rg-networking"

  subnet_id                      = azurerm_subnet.pe.id
  private_connection_resource_id = azurerm_storage_account.storage.id
  subresource_names              = ["blob"]

  # Automatic DNS integration
  private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Custom IP Configuration

```hcl
module "private_endpoint_custom_ip" {
  source = "../../modules/private-endpoint"

  name                = "pe-storage-custom"
  location            = "eastus"
  resource_group_name = "rg-networking"

  subnet_id                      = azurerm_subnet.pe.id
  private_connection_resource_id = azurerm_storage_account.example.id
  subresource_names              = ["blob"]

  # Specify custom private IP
  ip_configurations = [
    {
      name               = "custom-ip-config"
      private_ip_address = "10.0.1.10"
      subresource_name   = "blob"
      member_name        = null
    }
  ]

  private_dns_zone_ids = [azurerm_private_dns_zone.blob.id]
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
| name | Name of private endpoint | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| subnet_id | Subnet ID for private endpoint | `string` | n/a | yes |
| private_connection_resource_id | Target resource ID | `string` | n/a | yes |
| subresource_names | List of subresource names | `list(string)` | `null` | yes |
| is_manual_connection | Require manual approval | `bool` | `false` | no |
| request_message | Approval request message | `string` | `"Please approve..."` | no |
| private_dns_zone_ids | Private DNS zone IDs | `list(string)` | `null` | no |
| ip_configurations | Custom IP configurations | `list(object)` | `[]` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_endpoint_id | The ID of the private endpoint |
| private_endpoint_name | The name of the private endpoint |
| private_ip_address | The private IP address |
| network_interface_id | The network interface ID |
| custom_dns_configs | Custom DNS configurations |

## Supported Azure Services

### Storage
- **blob**: Blob storage
- **file**: File storage
- **queue**: Queue storage
- **table**: Table storage
- **dfs**: Data Lake Gen2

### Databases
- **sqlServer**: SQL Database/MI
- **mysqlServer**: MySQL
- **postgresqlServer**: PostgreSQL
- **mariadbServer**: MariaDB
- **Sql**: Cosmos DB (SQL API)
- **MongoDB**: Cosmos DB (MongoDB API)

### Web & App
- **sites**: App Service, Function Apps
- **gateway**: Application Gateway

### Analytics
- **dataFactory**: Data Factory
- **SqlOnDemand**: Synapse Analytics

### AI & ML
- **registry**: Container Registry
- **vault**: Key Vault
- **searchService**: Cognitive Search

### Others
- **namespace**: Event Hub, Service Bus
- **redisCache**: Redis Cache
- **configurationStores**: App Configuration

## Private DNS Zone Names

| Service | DNS Zone |
|---------|----------|
| Blob Storage | privatelink.blob.core.windows.net |
| File Storage | privatelink.file.core.windows.net |
| Queue Storage | privatelink.queue.core.windows.net |
| Table Storage | privatelink.table.core.windows.net |
| SQL Database | privatelink.database.windows.net |
| Key Vault | privatelink.vaultcore.azure.net |
| App Service | privatelink.azurewebsites.net |
| Container Registry | privatelink.azurecr.io |
| Cosmos DB (SQL) | privatelink.documents.azure.com |

## Best Practices

1. **Network Isolation**
   - Use dedicated subnet for private endpoints
   - Apply NSG rules to control traffic
   - Disable public network access on PaaS services

2. **DNS Configuration**
   - Always configure private DNS zones
   - Link DNS zones to all relevant VNets
   - Use Azure-provided DNS (168.63.129.16)

3. **Naming Convention**
   - Use descriptive names: `pe-{service}-{subresource}`
   - Example: `pe-storage-blob`, `pe-sql-server`

4. **Security**
   - Use manual approval for external connections
   - Monitor connection status
   - Audit private endpoint access

5. **Organization**
   - Group private endpoints in dedicated subnet
   - Use resource tags for management
   - Document service dependencies

## Troubleshooting

### DNS Resolution Issues
```bash
# Test DNS resolution
nslookup storageacct.blob.core.windows.net

# Should resolve to private IP (10.x.x.x)
# If resolving to public IP, check:
# 1. Private DNS zone linked to VNet
# 2. DNS zone name matches service
# 3. VNet DNS set to Azure-provided (168.63.129.16)
```

### Connection Failures
1. Verify private endpoint is in "Approved" state
2. Check subnet NSG allows traffic
3. Ensure service firewall allows VNet/subnet
4. Verify service public access is disabled

### Manual Approval Pending
```bash
# Check connection status
az network private-endpoint show \
  --name pe-storage-blob \
  --resource-group rg-networking \
  --query 'privateLinkServiceConnections[0].privateLinkServiceConnectionState'
```

## Common Patterns

### Hub-and-Spoke with Shared Private Endpoints
- Create private endpoints in hub VNet
- Link private DNS zones to all spokes
- Spoke workloads access via private connectivity

### Per-Environment Isolation
- Separate private endpoints per environment
- Environment-specific private DNS zones
- Isolated network security policies

## License

MIT
