# Azure Bastion Module

Production-ready Terraform module for creating and managing Azure Bastion for secure RDP/SSH access to VMs without public IPs.

## Features

- ✅ Standard and Basic SKU support
- ✅ Zone-redundant public IP
- ✅ Native client support (SSH/RDP tunneling)
- ✅ Shareable links for external access
- ✅ IP-based connection
- ✅ File copy/paste support
- ✅ Auto-scaling with scale units
- ✅ Production-ready defaults

## Usage

### Basic Bastion (Standard SKU)

```hcl
module "bastion" {
  source = "../../modules/azure-bastion"

  name                = "bastion-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"

  # AzureBastionSubnet (must be /26 or larger)
  subnet_id = azurerm_subnet.bastion.id

  # Standard SKU with all features
  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = false
  tunneling_enabled      = true

  # Zone redundancy
  zones = ["1", "2", "3"]

  # Scaling (2-50 scale units)
  scale_units = 4

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Basic SKU (Cost-Optimized)

```hcl
module "bastion_basic" {
  source = "../../modules/azure-bastion"

  name                = "bastion-dev"
  location            = "eastus"
  resource_group_name = "rg-dev"

  subnet_id = azurerm_subnet.bastion.id

  # Basic SKU (lower cost, no advanced features)
  sku = "Basic"

  tags = {
    Environment = "Development"
  }
}
```

### With Existing Public IP

```hcl
resource "azurerm_public_ip" "bastion" {
  name                = "pip-bastion"
  location            = "eastus"
  resource_group_name = "rg-networking"
  allocation_method   = "Static"
  sku                 = "Standard"
}

module "bastion" {
  source = "../../modules/azure-bastion"

  name                = "bastion-prod"
  location            = "eastus"
  resource_group_name = "rg-networking"

  subnet_id = azurerm_subnet.bastion.id

  # Use existing public IP
  create_public_ip = false
  public_ip_id     = azurerm_public_ip.bastion.id

  sku = "Standard"
}
```

### Production Hub with Bastion

```hcl
# Hub VNet
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub-prod"
  location            = "eastus"
  resource_group_name = "rg-hub"
  address_space       = ["10.0.0.0/16"]
}

# AzureBastionSubnet (name is required, minimum /26)
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_virtual_network.hub.resource_group_name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = ["10.0.254.0/26"]
}

# Bastion with production features
module "bastion" {
  source = "../../modules/azure-bastion"

  name                = "bastion-hub-prod"
  location            = "eastus"
  resource_group_name = "rg-hub"

  subnet_id = azurerm_subnet.bastion.id

  # Production configuration
  sku                    = "Standard"
  copy_paste_enabled     = true
  file_copy_enabled      = true
  ip_connect_enabled     = true
  shareable_link_enabled = false  # Disable for security
  tunneling_enabled      = true   # Enable native client

  # High availability
  zones       = ["1", "2", "3"]
  scale_units = 10  # Handle more concurrent sessions

  tags = {
    Environment = "Production"
    CostCenter  = "IT"
    Criticality = "High"
  }
}

# Example VM in spoke (no public IP needed)
resource "azurerm_network_interface" "vm" {
  name                = "nic-vm-spoke1"
  location            = "eastus"
  resource_group_name = "rg-spoke1"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.spoke_workload.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-spoke1-web"
  resource_group_name = "rg-spoke1"
  location            = "eastus"
  size                = "Standard_D2s_v3"
  admin_username      = "adminuser"
  admin_password      = "P@ssw0rd1234!"

  network_interface_ids = [
    azurerm_network_interface.vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-Datacenter"
    version   = "latest"
  }

  tags = {
    BastionAccess = "Required"
  }
}
```

### Native Client Connection

```bash
# Install Azure CLI extension
az extension add --name bastion

# SSH to Linux VM
az network bastion ssh \
  --name bastion-prod \
  --resource-group rg-networking \
  --target-resource-id /subscriptions/.../virtualMachines/vm-linux \
  --auth-type password \
  --username azureuser

# RDP to Windows VM
az network bastion rdp \
  --name bastion-prod \
  --resource-group rg-networking \
  --target-resource-id /subscriptions/.../virtualMachines/vm-windows
```

### IP-Based Connection

```bash
# Connect to VM by private IP (requires ip_connect_enabled = true)
az network bastion ssh \
  --name bastion-prod \
  --resource-group rg-networking \
  --target-ip-address 10.1.0.4 \
  --auth-type password \
  --username azureuser
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| azurerm | ~> 3.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| name | Name of Bastion host | `string` | n/a | yes |
| location | Azure region | `string` | n/a | yes |
| resource_group_name | Resource group name | `string` | n/a | yes |
| subnet_id | AzureBastionSubnet ID | `string` | n/a | yes |
| sku | SKU (Basic or Standard) | `string` | `"Standard"` | no |
| create_public_ip | Create new public IP | `bool` | `true` | no |
| public_ip_id | Existing public IP ID | `string` | `null` | conditional |
| zones | Availability zones | `list(string)` | `null` | no |
| copy_paste_enabled | Enable copy/paste | `bool` | `true` | no |
| file_copy_enabled | Enable file copy | `bool` | `false` | no |
| ip_connect_enabled | Enable IP-based connection | `bool` | `false` | no |
| shareable_link_enabled | Enable shareable links | `bool` | `false` | no |
| tunneling_enabled | Enable native client | `bool` | `false` | no |
| scale_units | Number of scale units (2-50) | `number` | `2` | no |
| tags | Resource tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bastion_id | The ID of the Bastion host |
| bastion_name | The name of the Bastion host |
| bastion_dns_name | The FQDN for the Bastion host |
| public_ip_id | The ID of the public IP |
| public_ip_address | The public IP address |

## SKU Comparison

| Feature | Basic | Standard |
|---------|-------|----------|
| **Price** | Lower | Higher |
| **Browser Access** | ✅ | ✅ |
| **Copy/Paste** | ❌ | ✅ |
| **File Copy** | ❌ | ✅ (RDP only) |
| **IP Connect** | ❌ | ✅ |
| **Shareable Links** | ❌ | ✅ |
| **Native Client** | ❌ | ✅ |
| **Scale Units** | 2 (fixed) | 2-50 |
| **Zone Redundancy** | ❌ | ✅ |

## Subnet Requirements

- **Name**: Must be exactly `AzureBastionSubnet`
- **Size**: Minimum /26 (64 addresses)
- **Recommended**: /24 for production
- **Location**: Same VNet as target VMs (or peered VNet)

## Scale Units

Each scale unit supports:
- **2 concurrent RDP sessions** per scale unit
- **3 concurrent SSH sessions** per scale unit
- Default: 2 scale units (4 RDP or 6 SSH sessions)
- Maximum: 50 scale units (100 RDP or 150 SSH sessions)

## Connection Methods

### 1. Azure Portal
- Navigate to target VM → Connect → Bastion
- Enter credentials
- Connect in browser

### 2. Native Client (CLI)
```bash
az network bastion ssh --name <bastion> --resource-group <rg> \
  --target-resource-id <vm-id> --auth-type password --username <user>
```

### 3. Shareable Link
- Generate link in portal
- Share with external users
- Time-limited access

## Security Best Practices

1. **Network Security**
   - Place Bastion in dedicated subnet
   - Use NSGs to control traffic
   - Disable shareable links unless required

2. **Access Control**
   - Use Azure RBAC for Bastion access
   - Require MFA for VM connections
   - Audit connection logs

3. **Monitoring**
   - Enable diagnostic logs
   - Monitor connection attempts
   - Set up alerts for unusual activity

4. **Cost Optimization**
   - Use Basic SKU for dev/test
   - Right-size scale units
   - Consider shared Bastion for multiple VNets

## Common Issues

### Cannot Connect to VM
1. Verify VM is in same/peered VNet
2. Check NSG rules allow Bastion traffic
3. Ensure VM has private IP
4. Verify Bastion subnet is /26 or larger

### Slow Performance
1. Increase scale units
2. Check VM performance
3. Verify network latency

### Feature Not Available
1. Verify Standard SKU is used
2. Check feature is enabled in variables
3. Ensure Azure CLI extension is updated

## Pricing Considerations

- **Bastion**: Charged per hour + scale units
- **Public IP**: Standard SKU charged hourly
- **Data Transfer**: Outbound data charges apply
- **Tip**: Use Basic SKU for non-production to save costs

## License

MIT
