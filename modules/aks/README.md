# Azure Kubernetes Service (AKS) Module

This module creates a production-ready Azure Kubernetes Service cluster with comprehensive security, monitoring, and operational features.

## Features

- **Private Cluster Support**: Option to create a private AKS cluster for enhanced security
- **Workload Identity**: Support for Azure AD Workload Identity for pod authentication
- **Azure Policy Integration**: Enable Azure Policy add-on for compliance and governance
- **Auto-scaling**: Support for cluster autoscaler on node pools
- **Network Integration**: Flexible network configurations with Azure CNI or Kubenet
- **Monitoring**: Integration with Azure Monitor and Log Analytics with comprehensive diagnostic settings
- **Microsoft Defender**: Optional Microsoft Defender for Containers integration
- **Key Vault Integration**: Azure Key Vault Secrets Provider addon support
- **Upgrade Management**: Automatic channel upgrades for cluster maintenance
- **Multi-zone Support**: Availability zone support for high availability
- **Diagnostic Settings**: Control plane logging (API server, controller manager, scheduler, audit logs)
- **Lifecycle Management**: Intelligent lifecycle rules to prevent accidental destruction

## Usage

### Basic Configuration

```hcl
module "aks" {
  source = "../../"

  name                = "my-aks-cluster"
  location            = "eastus"
  resource_group_name = "my-rg"
  dns_prefix          = "myaks"

  default_node_pool = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 3
  }

  tags = {
    Environment = "Production"
  }
}
```

### Advanced Configuration with Auto-scaling

```hcl
module "aks" {
  source = "../../"

  name                = "my-aks-cluster"
  location            = "eastus"
  resource_group_name = "my-rg"
  dns_prefix          = "myaks"
  kubernetes_version  = "1.28"

  default_node_pool = {
    name                = "system"
    vm_size             = "Standard_D2_v2"
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    zones               = ["1", "2", "3"]
  }

  network_profile = {
    network_plugin = "azure"
    network_policy = "azure"
    service_cidr   = "10.0.0.0/16"
    dns_service_ip = "10.0.0.10"
  }

  azure_ad_rbac_enabled = true

  additional_node_pools = {
    workload = {
      name                = "workload"
      vm_size             = "Standard_D4_v2"
      enable_auto_scaling = true
      min_count           = 2
      max_count           = 5
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
| name | The name of the AKS cluster | `string` | n/a | yes |
| location | The Azure region | `string` | n/a | yes |
| resource_group_name | The name of the resource group | `string` | n/a | yes |
| dns_prefix | DNS prefix for the cluster | `string` | n/a | yes |
| kubernetes_version | Version of Kubernetes | `string` | `null` | no |
| default_node_pool | Default node pool configuration | `object` | n/a | yes |
| identity_type | The type of identity | `string` | `"SystemAssigned"` | no |
| network_profile | Network profile configuration | `object` | See variables | no |
| azure_ad_rbac_enabled | Enable Azure AD RBAC | `bool` | `false` | no |
| azure_ad_rbac_config | Azure AD RBAC configuration | `object` | `{}` | no |
| role_based_access_control_enabled | Enable RBAC | `bool` | `true` | no |
| log_analytics_workspace_id | Log Analytics Workspace ID | `string` | `null` | no |
| additional_node_pools | Map of additional node pools | `map(object)` | `{}` | no |
| tags | A mapping of tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| id | The ID of the Kubernetes Cluster |
| name | The name of the Kubernetes Cluster |
| fqdn | The FQDN of the cluster |
| kube_config | Kubernetes configuration (sensitive) |
| kube_admin_config | Kubernetes admin configuration (sensitive) |
| node_resource_group | The node resource group |
| kubelet_identity | The kubelet identity |
| principal_id | The Principal ID of the System Assigned MSI |

## Notes

- When using auto-scaling, both `min_count` and `max_count` must be specified
- The `network_plugin` can be either "azure" or "kubenet"
- Azure AD RBAC requires appropriate permissions in your Azure AD tenant
