# Production App Service Environment Example

This example demonstrates deploying a production-ready App Service Environment v3 (ASEv3) with zone redundancy, enhanced security, comprehensive monitoring, and proper network configuration.

## Features Demonstrated

- **ASEv3**: Latest generation App Service Environment
- **Zone Redundancy**: High availability across 3 availability zones
- **Internal Load Balancing**: Complete isolation with private endpoints
- **Network Security**: Proper NSG configuration for ASE management
- **TLS Security**: TLS 1.0/1.1 disabled, strong cipher suites configured
- **Internal Encryption**: Traffic encrypted within ASE
- **Private DNS**: Automatic private DNS zone with wildcard records
- **Comprehensive Monitoring**: Platform logs sent to Log Analytics
- **Dedicated Subnet**: /24 subnet properly delegated to ASE

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Understanding of Azure networking and App Service
- Budget approval (ASEv3 has significant base cost)

## Important Notes

### Deployment Time
- **Initial Creation**: 2-4 hours
- **With Zone Redundancy**: May take longer
- Plan accordingly - this is not instant

### Cost Warning
ASEv3 has a base infrastructure cost of ~$1,000-$2,000/month (varies by region and zone redundancy) **even with zero apps deployed**. This is in addition to App Service Plan costs.

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration (will take 2-4 hours)
terraform apply

# Get outputs
terraform output
```

## Network Architecture

### Subnet Configuration
- **Address Space**: 10.0.1.0/24 (256 IP addresses)
- **Delegation**: Microsoft.Web/hostingEnvironments
- **Usage**: Dedicated exclusively to ASE
- **Cannot Share**: No other resources allowed in this subnet

### NSG Rules Required
1. **AppServiceManagement**: Allow inbound from Azure management
2. **AzureLoadBalancer**: Allow health monitoring
3. **VirtualNetwork**: Allow VNet traffic

### DNS Configuration
- **Zone**: `production-ase.appserviceenvironment.net`
- **Records Created**:
  - `*` → Internal IP (all apps)
  - `@` → Internal IP (root)
  - `*.scm` → Internal IP (SCM/Kudu)

## Security Configuration

### TLS Settings
```hcl
cluster_settings = [
  {
    name  = "DisableTls1.0"
    value = "1"
  },
  {
    name  = "DisableTls1.1"
    value = "1"
  }
]
```

### Cipher Suites
Only strong cipher suites are enabled:
- TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
- TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256

### Internal Encryption
All traffic within the ASE is encrypted.

## Accessing Apps

Since this is an internal ASE, apps are not publicly accessible. Access options:

### Option 1: VPN/ExpressRoute (Recommended)
Connect your corporate network to the Azure VNet:
```bash
# No additional configuration needed
# Apps accessible via private DNS names
```

### Option 2: Azure Bastion + Jump Box
Deploy a jump box in the same VNet:
```bash
# RDP/SSH to jump box via Bastion
# Access apps from jump box browser
```

### Option 3: Application Gateway
Public-facing gateway with backend to internal ASE:
```hcl
resource "azurerm_application_gateway" "main" {
  # Configure App Gateway
  # Backend pool points to ASE apps
}
```

### Option 4: Private Link (Advanced)
Use Private Endpoints for selective external access.

## Deploying Apps to ASE

### Create App Service Plan (Isolated v2 SKU Required)
```hcl
resource "azurerm_service_plan" "ase" {
  name                       = "ase-plan"
  resource_group_name        = azurerm_resource_group.example.name
  location                   = azurerm_resource_group.example.location
  os_type                    = "Linux"
  sku_name                   = "I1v2"
  app_service_environment_id = module.ase.id
}
```

### Create App Service
```hcl
resource "azurerm_linux_web_app" "app" {
  name                = "my-app"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.ase.id

  site_config {}
}
```

### Access App
```
https://my-app.production-ase.appserviceenvironment.net
```

## Zone Redundancy

Zone redundancy is enabled (`zone_redundant = true`) which provides:

### Benefits
- Automatic failover if entire zone fails
- 99.99% SLA for App Service Plans
- No application code changes required
- Transparent to applications

### Cost Impact
- Approximately 2x the base ASE cost
- Higher availability justifies cost for production

### Regional Availability
Verify zone redundancy support in your region:
- East US 2: ✓ Supported
- West Europe: ✓ Supported
- Southeast Asia: ✓ Supported
- Not all regions support this feature

## Monitoring and Diagnostics

### Platform Logs
Sent to Log Analytics:
- ASE deployment events
- Configuration changes
- Health status
- Performance metrics

### Recommended Alerts
1. **ASE Health**: Alert on unhealthy status
2. **Front End CPU**: Alert on high CPU usage
3. **Worker CPU**: Alert on worker saturation
4. **Memory**: Alert on memory pressure
5. **HTTP Errors**: Alert on elevated error rates

### View Metrics
```bash
# In Azure Portal
# ASE > Monitoring > Metrics
# Select metric category and view graphs
```

## Scaling and Capacity

### Front Ends
- Auto-scaled based on load
- Minimum 2 front ends (zone redundancy)
- Handles SSL termination and routing

### Workers
- Deploy App Service Plans on workers
- Scale workers based on app requirements
- Monitor worker capacity

### Isolated v2 SKUs
- I1v2: 2 cores, 8 GB RAM
- I2v2: 4 cores, 16 GB RAM
- I3v2: 8 cores, 32 GB RAM
- I4v2: 16 cores, 64 GB RAM
- I5v2: 32 cores, 128 GB RAM
- I6v2: 64 cores, 256 GB RAM

## Disaster Recovery

### Backup Strategy
1. App Service built-in backup for apps
2. Database backups for app data
3. Configuration stored in source control

### Multi-Region DR
For true DR, deploy second ASE in another region:
```hcl
module "ase_dr" {
  source = "../../"
  
  name     = "dr-ase"
  location = "westus2"
  # ... other configuration
}
```

Use Azure Traffic Manager or Front Door to route between regions.

## Cost Management

### Monthly Costs (Approximate)
- **Base ASE Infrastructure**: $1,000-$1,500
- **Zone Redundancy**: Additional $1,000-$1,500
- **App Service Plans**: $214+ per I1v2 instance
- **Data Transfer**: Varies by usage

### Cost Optimization
1. **Share ASE**: Deploy multiple apps/environments
2. **Right-size Plans**: Don't over-provision
3. **Auto-scaling**: Scale plans based on demand
4. **Avoid Idle Resources**: Remove unused plans

## Troubleshooting

### ASE Stuck in "Creating" State
- Check NSG rules on subnet
- Verify subnet has required space
- Ensure no conflicts with other resources
- Check Azure status page for platform issues

### Cannot Access Apps
- Verify private DNS is linked to VNet
- Check NSG rules allow necessary traffic
- Confirm you're connecting from within VNet or via VPN
- Validate DNS resolution

### Slow Deployment
- ASEv3 deployments are inherently slow (2-4 hours)
- Zone redundant deployments may take longer
- This is expected and normal

## Migration from ASEv2

If migrating from ASEv2:
1. Deploy new ASEv3 (side-by-side approach)
2. Deploy apps to new ASE
3. Test thoroughly
4. Update DNS/routing to new ASE
5. Decommission old ASEv2

## Next Steps

After ASE deployment:
1. Deploy App Service Plans
2. Deploy applications
3. Configure custom domains and SSL
4. Set up monitoring alerts
5. Document access procedures
6. Train operations team
7. Establish backup procedures
8. Test failover scenarios

## Support and Resources

- [ASEv3 Documentation](https://docs.microsoft.com/azure/app-service/environment/overview)
- [ASEv3 Networking](https://docs.microsoft.com/azure/app-service/environment/networking)
- [ASEv3 Pricing](https://azure.microsoft.com/pricing/details/app-service/)

## Cleanup Warning

**DO NOT** destroy the ASE without careful planning:
- Deletion is permanent and cannot be undone
- All apps in the ASE will be deleted
- DNS records will need to be manually cleaned up
- Takes 1-2 hours to fully delete
