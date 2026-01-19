output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = module.aks.id
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = module.aks.fqdn
}

output "kube_config" {
  description = "Kubernetes configuration"
  value       = module.aks.kube_config
  sensitive   = true
}
