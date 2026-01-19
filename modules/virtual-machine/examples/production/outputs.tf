output "vm_id" {
  description = "The ID of the virtual machine"
  value       = module.windows_vm.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = module.windows_vm.name
}

output "vm_private_ip" {
  description = "The private IP address of the VM"
  value       = module.windows_vm.private_ip_address
}

output "vm_principal_id" {
  description = "The principal ID of the managed identity"
  value       = module.windows_vm.principal_id
}

output "vm_data_disks" {
  description = "The data disk IDs"
  value       = module.windows_vm.data_disk_ids
}
