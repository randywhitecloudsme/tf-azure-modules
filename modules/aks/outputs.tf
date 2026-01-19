output "id" {
  description = "The ID of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "name" {
  description = "The name of the Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "fqdn" {
  description = "The FQDN of the Azure Kubernetes Managed Cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "private_fqdn" {
  description = "The FQDN for the private cluster (only set when private_cluster_enabled is true)"
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "kube_config" {
  description = "Kubernetes configuration file"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kube_admin_config" {
  description = "Kubernetes admin configuration file"
  value       = azurerm_kubernetes_cluster.this.kube_admin_config_raw
  sensitive   = true
}

output "node_resource_group" {
  description = "The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "kubelet_identity" {
  description = "The kubelet identity"
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "principal_id" {
  description = "The Principal ID of the System Assigned Managed Service Identity"
  value       = azurerm_kubernetes_cluster.this.identity[0].principal_id
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL that is associated with the cluster"
  value       = azurerm_kubernetes_cluster.this.oidc_issuer_url
}

output "identity" {
  description = "The complete managed identity block of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.identity
}
