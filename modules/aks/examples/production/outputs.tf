output "aks_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.id
}

output "aks_name" {
  description = "The name of the AKS cluster"
  value       = module.aks.name
}

output "aks_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

output "aks_private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = module.aks.private_fqdn
}

output "oidc_issuer_url" {
  description = "The OIDC issuer URL for workload identity"
  value       = module.aks.oidc_issuer_url
}

output "kubelet_identity" {
  description = "The kubelet identity"
  value       = module.aks.kubelet_identity
}

output "node_resource_group" {
  description = "The auto-generated resource group for AKS nodes"
  value       = module.aks.node_resource_group
}
