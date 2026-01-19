output "vmss_id" {
  description = "The ID of the VMSS"
  value       = module.linux_vmss.id
}

output "vmss_name" {
  description = "The name of the VMSS"
  value       = module.linux_vmss.name
}

output "vmss_unique_id" {
  description = "The unique ID of the VMSS"
  value       = module.linux_vmss.unique_id
}
