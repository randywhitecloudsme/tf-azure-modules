output "vm_id" {
  description = "The ID of the virtual machine"
  value       = module.linux_vm.id
}

output "vm_name" {
  description = "The name of the virtual machine"
  value       = module.linux_vm.name
}

output "vm_private_ip" {
  description = "The private IP address of the VM"
  value       = module.linux_vm.private_ip_address
}

output "vm_identity" {
  description = "The managed identity of the VM"
  value       = module.linux_vm.identity
}
