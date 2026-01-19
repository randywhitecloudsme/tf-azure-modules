# Production AKS Cluster Example

This example demonstrates how to create a production-ready AKS cluster with all enterprise features enabled.

## Features Demonstrated

- **Private Cluster**: API server is not publicly accessible
- **Workload Identity**: Enables Azure AD Workload Identity for secure pod authentication
- **Azure Policy**: Enforces compliance policies on the cluster
- **Multi-zone High Availability**: Node pools distributed across availability zones
- **Autoscaling**: Cluster autoscaler enabled on all node pools
- **Advanced Networking**: Azure CNI with Azure Network Policy
- **Monitoring**: Full diagnostic settings with Log Analytics integration
- **Microsoft Defender**: Enhanced security scanning for containers
- **Key Vault Integration**: Secrets Provider with automatic rotation
- **Managed Upgrades**: Automatic channel upgrades for maintenance

## Usage

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply

# Get kubeconfig (requires Azure AD authentication)
az aks get-credentials --resource-group production-aks-rg --name production-aks-cluster

# Verify cluster access
kubectl get nodes
```

## Prerequisites

- Azure subscription with appropriate permissions
- Azure CLI installed and authenticated
- Terraform >= 1.0
- kubectl installed
- Azure AD admin group created (update `admin_group_object_ids` in main.tf)

## Security Considerations

1. **Private Cluster**: The API server is only accessible from the VNet or peered networks
2. **Local Accounts Disabled**: Enforces Azure AD authentication only
3. **RBAC**: Azure AD RBAC enabled for fine-grained access control
4. **Network Policy**: Azure Network Policy controls pod-to-pod traffic
5. **Microsoft Defender**: Provides runtime security and vulnerability scanning

## Cost Optimization

- **SKU Tier**: Using Standard tier for production workloads (includes SLA)
- **Autoscaling**: Scales down during low usage to reduce costs
- **Ephemeral OS Disks**: Used on workload node pool for better performance and lower cost

## Monitoring and Observability

The cluster sends the following logs to Log Analytics:
- kube-apiserver logs
- kube-controller-manager logs
- kube-scheduler logs
- kube-audit logs
- cluster-autoscaler logs
- All metrics

## Workload Identity Setup

To use workload identity with your pods:

1. Create a managed identity in Azure
2. Federate it with the OIDC issuer URL from outputs
3. Grant the identity permissions to Azure resources
4. Annotate your service account with the client ID
5. Use the service account in your pod specs

Example:
```bash
# Get OIDC issuer URL
OIDC_ISSUER=$(terraform output -raw oidc_issuer_url)

# Create federated credential
az identity federated-credential create \
  --name my-federated-credential \
  --identity-name my-managed-identity \
  --resource-group my-rg \
  --issuer "$OIDC_ISSUER" \
  --subject system:serviceaccount:default:my-service-account
```
