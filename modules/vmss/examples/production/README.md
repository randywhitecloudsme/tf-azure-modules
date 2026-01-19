# Production Windows VMSS with Autoscaling Example

This example demonstrates a production-ready Windows Server Virtual Machine Scale Set with comprehensive autoscaling, rolling upgrades, automatic instance repair, and load balancer integration.

## Features Demonstrated

- **Windows Server 2022 Azure Edition**: Latest Windows Server optimized for Azure
- **Multi-zone High Availability**: Distributed across 3 availability zones with zone balancing
- **Azure Load Balancer**: Internal load balancer with health probes
- **Autoscaling**: CPU-based autoscaling from 3 to 15 instances
- **Rolling Upgrades**: Controlled updates in 20% batches with automatic rollback
- **Automatic Instance Repair**: Self-healing based on load balancer health probes
- **Encryption at Host**: All disks encrypted at rest
- **Premium Storage**: Premium SSD for optimal performance
- **Comprehensive Monitoring**: Metrics sent to Log Analytics
- **Email Notifications**: Autoscaling event notifications

## Prerequisites

- Azure subscription with appropriate permissions
- Terraform >= 1.0
- Encryption at host feature enabled: `az feature register --namespace Microsoft.Compute --name EncryptionAtHost`

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Get outputs
terraform output
```

## Autoscaling Configuration

The VMSS scales based on CPU utilization:

### Scale Out (Add Instances)
- **Trigger**: CPU > 75% for 5 minutes
- **Action**: Add 2 instances
- **Cooldown**: 5 minutes

### Scale In (Remove Instances)
- **Trigger**: CPU < 25% for 5 minutes
- **Action**: Remove 1 instance
- **Cooldown**: 5 minutes

### Capacity Limits
- **Minimum**: 3 instances
- **Default**: 5 instances
- **Maximum**: 15 instances

## Rolling Upgrade Strategy

When updating the VMSS (e.g., changing VM image):

1. **Batch Size**: 20% of instances updated simultaneously
2. **Health Check**: Load balancer probe validates health
3. **Pause**: 30 seconds between batches
4. **Rollback**: Automatic rollback if >20% become unhealthy
5. **Validation**: Max 20% unhealthy instances allowed

## Automatic Instance Repair

- **Health Monitoring**: Load balancer HTTP probe on port 80
- **Grace Period**: 30 minutes after instance creation
- **Repair Action**: Unhealthy instances automatically replaced
- **Health Check Path**: `/` (customize for your application)

## Load Balancer Configuration

- **Type**: Internal load balancer (private IP)
- **SKU**: Standard (supports availability zones)
- **Health Probe**: HTTP probe on port 80
- **Load Balancing Rule**: Port 80 TCP
- **Backend Pool**: Automatically populated by VMSS

## Security Considerations

1. **Password Management**:
   ```hcl
   # Production example - use Key Vault
   data "azurerm_key_vault_secret" "admin_password" {
     name         = "vmss-admin-password"
     key_vault_id = var.key_vault_id
   }
   
   admin_password = data.azurerm_key_vault_secret.admin_password.value
   ```

2. **Network Security**:
   - Internal load balancer (no public IP)
   - Place NSG on subnet
   - Use Azure Bastion for administrative access

3. **Encryption**:
   - Encryption at host enabled
   - Consider customer-managed keys via Disk Encryption Set

4. **Monitoring**:
   - All metrics sent to Log Analytics
   - Set up alerting for critical metrics
   - Enable VM Insights for detailed monitoring

## Cost Optimization

- **SKU**: Standard_D2s_v3 (2 vCPUs, 8GB RAM) - adjust based on workload
- **Autoscaling**: Automatically scales down during low demand
- **Spot Instances**: Consider for fault-tolerant workloads (not in this example)
- **Reserved Instances**: Commit to base capacity for cost savings

## Application Deployment

For application deployment on VMSS instances:

### Option 1: Custom Script Extension
```hcl
# Add to VMSS module
extension {
  name                 = "CustomScript"
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  
  settings = jsonencode({
    fileUris = ["https://storage.blob.core.windows.net/scripts/install-app.ps1"]
  })
  
  protected_settings = jsonencode({
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File install-app.ps1"
  })
}
```

### Option 2: Custom Image with Packer
1. Build golden image with Packer
2. Reference custom image in `source_image_id`
3. Instances start pre-configured

### Option 3: Configuration Management
- Azure Automation DSC
- Chef
- Puppet
- Ansible

## Monitoring and Alerts

Recommended alerts to configure:

1. **Instance Health**: Alert when unhealthy instances > threshold
2. **CPU Usage**: Alert on sustained high CPU
3. **Memory Pressure**: Alert on low available memory
4. **Disk Space**: Alert on low disk space
5. **Autoscale Events**: Notification on scale operations
6. **Failed Updates**: Alert on failed rolling upgrades

## Disaster Recovery

Considerations for DR:

1. **Backup Strategy**: Use Azure Backup for stateful data
2. **Multi-region**: Deploy identical VMSS in secondary region
3. **Traffic Manager**: Route traffic between regions
4. **Data Replication**: Replicate stateful data to secondary region

## Testing Autoscaling

```bash
# SSH into an instance and generate CPU load
az vmss list-instances --name production-win-vmss --resource-group production-vmss-rg

# RDP to an instance via Bastion
# Run CPU stress test
# Monitor autoscaling in Azure Portal

# View autoscale history
az monitor autoscale show \
  --resource-group production-vmss-rg \
  --name production-win-vmss-autoscale
```

## Troubleshooting

### Instance Repair Not Working
- Verify health probe is correctly configured
- Check grace period (30 minutes after creation)
- Ensure instances fail health check consistently

### Rolling Upgrade Stuck
- Check instance health via load balancer probe
- Verify upgrade policy percentages
- Review VMSS update history in portal

### Autoscaling Not Triggering
- Verify metric thresholds are being crossed
- Check cooldown periods
- Review autoscale rule configuration

## Next Steps

1. Configure application deployment method
2. Set up Azure Backup for data disks
3. Implement NSG rules
4. Configure Azure Bastion
5. Set up monitoring alerts
6. Document application-specific configuration
7. Perform load testing to validate autoscaling
8. Test rolling upgrade procedure
