# Production Windows VM Example

This example demonstrates how to create a production-ready Windows Server virtual machine with comprehensive security, monitoring, and data disk configuration.

## Features Demonstrated

- **Windows Server 2022 Azure Edition**: Latest Windows Server with Azure-optimized features
- **High Availability**: Deployed in availability zone 1
- **Static Private IP**: Fixed private IP address for consistent connectivity
- **Encryption at Host**: Data-at-rest encryption enabled
- **Premium Storage**: Premium SSD for OS and data disks
- **Multiple Data Disks**: 512GB and 1TB data disks with optimized caching
- **Comprehensive Monitoring**: Azure Monitor Agent and Dependency Agent enabled
- **Automated Patching**: AutomaticByPlatform patch mode for managed updates
- **System-Assigned Managed Identity**: For secure Azure resource access
- **Diagnostic Settings**: Metrics sent to Log Analytics workspace

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

# Get the VM's private IP
terraform output vm_private_ip
```

## Security Considerations

1. **Password Management**: The example uses a hardcoded password for demonstration. In production:
   - Store passwords in Azure Key Vault
   - Reference them using `data.azurerm_key_vault_secret`
   - Never commit passwords to source control

2. **Network Isolation**: 
   - No public IP attached
   - Access via Azure Bastion, VPN, or ExpressRoute recommended
   - Place in private subnet with NSG rules

3. **Encryption**: 
   - Encryption at host enabled for all disks
   - Consider using customer-managed keys via Disk Encryption Set

4. **Managed Identity**:
   - System-assigned managed identity enabled
   - Grant only necessary RBAC permissions
   - Use for authenticating to Azure services

## Cost Optimization

- **VM Size**: Standard_D4s_v3 (4 vCPUs, 16GB RAM) suitable for medium workloads
- **Premium Storage**: Provides better performance and SLA but costs more
- **Availability Zone**: Provides SLA but may increase costs
- **Auto-shutdown**: Consider implementing auto-shutdown schedules for dev/test

## Monitoring Setup

The VM sends metrics to Log Analytics workspace:
- Performance counters
- Event logs
- Dependency mapping (with Dependency Agent)

To view VM Insights:
```bash
# Navigate to Azure Portal > Virtual Machines > [VM Name] > Monitoring > Insights
```

## Backup and Disaster Recovery

While not configured in this example, production VMs should have:
1. Azure Backup configured with appropriate policy
2. Recovery Services Vault in secondary region
3. Disaster recovery with Azure Site Recovery
4. Regular restore testing

Add backup configuration:
```hcl
resource "azurerm_backup_protected_vm" "vm" {
  resource_group_name = azurerm_recovery_services_vault.vault.resource_group_name
  recovery_vault_name = azurerm_recovery_services_vault.vault.name
  source_vm_id        = module.windows_vm.id
  backup_policy_id    = azurerm_backup_policy_vm.policy.id
}
```

## Disk Configuration

- **OS Disk**: 256GB Premium SSD with ReadWrite caching
- **Data Disk 1**: 512GB Premium SSD with ReadOnly caching (optimized for read-heavy workloads)
- **Data Disk 2**: 1TB Premium SSD with no caching (optimized for write-heavy workloads like databases)

## Patching Strategy

- **Patch Mode**: AutomaticByPlatform - Microsoft manages patching schedule
- **Assessment Mode**: AutomaticByPlatform - Automated compliance assessment
- **Automatic Updates**: Enabled for critical security updates
- **Maintenance Window**: Configure via Azure Update Management for controlled patching

## Next Steps

1. Configure NSG rules for required traffic
2. Set up Azure Bastion for secure remote access
3. Configure Azure Backup
4. Set up monitoring alerts
5. Document application-specific configuration
6. Implement auto-shutdown for cost savings (dev/test only)
