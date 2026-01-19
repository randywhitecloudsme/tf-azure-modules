output "vmss_id" {
  description = "The ID of the VMSS"
  value       = module.windows_vmss.id
}

output "vmss_name" {
  description = "The name of the VMSS"
  value       = module.windows_vmss.name
}

output "vmss_principal_id" {
  description = "The principal ID of the managed identity"
  value       = module.windows_vmss.principal_id
}

output "autoscale_setting_id" {
  description = "The ID of the autoscale setting"
  value       = module.windows_vmss.autoscale_setting_id
}

output "load_balancer_frontend_ip" {
  description = "The frontend IP of the load balancer"
  value       = azurerm_lb.example.frontend_ip_configuration[0].private_ip_address
}
