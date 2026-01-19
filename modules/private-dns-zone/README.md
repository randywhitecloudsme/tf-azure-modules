# Azure Private DNS Zone Module

Production-ready Terraform module for creating and managing Azure Private DNS Zones with virtual network links and DNS records.

## Features

- ✅ Private DNS Zone with custom SOA record
- ✅ Virtual network links with auto-registration
- ✅ Complete DNS record support (A, AAAA, CNAME, MX, PTR, SRV, TXT)
- ✅ Input validation for all record types
- ✅ Support for multiple virtual network links
- ✅ Production-ready defaults

## Usage

### Basic Private DNS Zone

```hcl
module "private_dns_zone" {
  source = "../../modules/private-dns-zone"

  name                = "privatelink.database.windows.net"
  resource_group_name = "rg-network-prod"

  virtual_network_links = {
    hub = {
      name               = "vnet-hub-link"
      virtual_network_id = azurerm_virtual_network.hub.id
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Private DNS Zone with Records

```hcl
module "private_dns_zone_app" {
  source = "../../modules/private-dns-zone"

  name                = "app.internal"
  resource_group_name = "rg-network-prod"

  virtual_network_links = {
    hub = {
      name                 = "vnet-hub-link"
      virtual_network_id   = azurerm_virtual_network.hub.id
      registration_enabled = false
    }
    spoke1 = {
      name                 = "vnet-spoke1-link"
      virtual_network_id   = azurerm_virtual_network.spoke1.id
      registration_enabled = true
    }
  }

  # A Records
  a_records = {
    web = {
      name    = "web"
      ttl     = 300
      records = ["10.0.1.4", "10.0.1.5"]
    }
    api = {
      name    = "api"
      ttl     = 300
      records = ["10.0.2.4"]
    }
  }

  # CNAME Records
  cname_records = {
    www = {
      name   = "www"
      ttl    = 3600
      record = "web.app.internal"
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Production Private DNS Zone with Full Configuration

```hcl
module "private_dns_zone_production" {
  source = "../../modules/private-dns-zone"

  name                = "contoso.internal"
  resource_group_name = "rg-network-prod"

  # Custom SOA Record
  soa_record = {
    email        = "admin@contoso.com"
    expire_time  = 2419200
    minimum_ttl  = 300
    refresh_time = 3600
    retry_time   = 300
    ttl          = 3600
  }

  # Virtual Network Links
  virtual_network_links = {
    hub = {
      name                 = "vnet-hub-link"
      virtual_network_id   = azurerm_virtual_network.hub.id
      registration_enabled = false
    }
    spoke_web = {
      name                 = "vnet-spoke-web-link"
      virtual_network_id   = azurerm_virtual_network.spoke_web.id
      registration_enabled = true
    }
    spoke_data = {
      name                 = "vnet-spoke-data-link"
      virtual_network_id   = azurerm_virtual_network.spoke_data.id
      registration_enabled = true
    }
  }

  # A Records
  a_records = {
    web_lb = {
      name    = "web"
      ttl     = 300
      records = ["10.1.1.10"]
    }
    app_lb = {
      name    = "app"
      ttl     = 300
      records = ["10.1.2.10"]
    }
    db_cluster = {
      name    = "db"
      ttl     = 60
      records = ["10.1.3.10", "10.1.3.11", "10.1.3.12"]
    }
  }

  # CNAME Records
  cname_records = {
    www = {
      name   = "www"
      ttl    = 3600
      record = "web.contoso.internal"
    }
    admin = {
      name   = "admin"
      ttl    = 3600
      record = "app.contoso.internal"
    }
  }

  # MX Records
  mx_records = {
    mail = {
      name = "@"
      ttl  = 3600
      records = [
        {
          preference = 10
          exchange   = "mail1.contoso.internal"
        },
        {
          preference = 20
          exchange   = "mail2.contoso.internal"
        }
      ]
    }
  }

  # SRV Records
  srv_records = {
    ldap = {
      name = "_ldap._tcp"
      ttl  = 3600
      records = [
        {
          priority = 0
          weight   = 5
          port     = 389
          target   = "dc1.contoso.internal"
        },
        {
          priority = 0
          weight   = 5
          port     = 389
          target   = "dc2.contoso.internal"
        }
      ]
    }
  }

  # TXT Records
  txt_records = {
    verification = {
      name    = "@"
      ttl     = 3600
      records = ["v=spf1 include:contoso.com ~all"]
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
    CostCenter  = "IT"
  }
}
```

### Private DNS for Azure Private Endpoints

```hcl
# Storage Account Private DNS Zone
module "private_dns_storage_blob" {
  source = "../../modules/private-dns-zone"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = "rg-network-prod"

  virtual_network_links = {
    hub = {
      name               = "vnet-hub-link"
      virtual_network_id = azurerm_virtual_network.hub.id
    }
  }

  a_records = {
    storage = {
      name    = azurerm_storage_account.example.name
      ttl     = 300
      records = [azurerm_private_endpoint.storage.private_service_connection[0].private_ip_address]
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}

# Key Vault Private DNS Zone
module "private_dns_keyvault" {
  source = "../../modules/private-dns-zone"

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = "rg-network-prod"

  virtual_network_links = {
    hub = {
      name               = "vnet-hub-link"
      virtual_network_id = azurerm_virtual_network.hub.id
    }
  }

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
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
| name | The name of the Private DNS Zone | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| soa_record | SOA record configuration | `object` | `null` | no |
| virtual_network_links | Map of virtual network links | `map(object)` | `{}` | no |
| a_records | Map of A records | `map(object)` | `{}` | no |
| aaaa_records | Map of AAAA records | `map(object)` | `{}` | no |
| cname_records | Map of CNAME records | `map(object)` | `{}` | no |
| mx_records | Map of MX records | `map(object)` | `{}` | no |
| ptr_records | Map of PTR records | `map(object)` | `{}` | no |
| srv_records | Map of SRV records | `map(object)` | `{}` | no |
| txt_records | Map of TXT records | `map(object)` | `{}` | no |
| tags | Tags to apply | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| private_dns_zone_id | The ID of the Private DNS Zone |
| private_dns_zone_name | The name of the Private DNS Zone |
| virtual_network_link_ids | Map of VNet link IDs |
| a_record_ids | Map of A record IDs |
| cname_record_ids | Map of CNAME record IDs |

## Common Private DNS Zone Names for Azure Services

| Service | Private DNS Zone Name |
|---------|----------------------|
| Storage Blob | `privatelink.blob.core.windows.net` |
| Storage File | `privatelink.file.core.windows.net` |
| Storage Queue | `privatelink.queue.core.windows.net` |
| Storage Table | `privatelink.table.core.windows.net` |
| Azure SQL Database | `privatelink.database.windows.net` |
| Azure Cosmos DB (SQL) | `privatelink.documents.azure.com` |
| Azure Key Vault | `privatelink.vaultcore.azure.net` |
| Azure Container Registry | `privatelink.azurecr.io` |
| Azure App Service | `privatelink.azurewebsites.net` |
| Azure Kubernetes Service | `privatelink.<region>.azmk8s.io` |

## Best Practices

1. **Zone Naming**: Follow Azure Private Link DNS zone naming conventions for PaaS services
2. **VNet Links**: Link all VNets that need to resolve the private DNS zone
3. **Auto-registration**: Enable only for VNets where VMs should auto-register
4. **TTL Values**: Use appropriate TTL values (300-3600 seconds for most records)
5. **Hub-Spoke**: In hub-spoke topology, link the Private DNS Zone to the hub VNet
6. **Conditional Forwarding**: Configure on-premises DNS to forward to Azure DNS (168.63.129.16)
7. **Record Management**: Use Terraform to manage all DNS records for consistency

## DNS Record Types

- **A**: Maps hostname to IPv4 address
- **AAAA**: Maps hostname to IPv6 address
- **CNAME**: Creates an alias to another hostname
- **MX**: Mail exchange records for email routing
- **PTR**: Reverse DNS lookup (IP to hostname)
- **SRV**: Service location records
- **TXT**: Text records for verification and SPF

## License

MIT
