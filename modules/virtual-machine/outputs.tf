output "id" {
  description = "The ID of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].id : azurerm_windows_virtual_machine.this[0].id
}

output "name" {
  description = "The name of the virtual machine"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].name : azurerm_windows_virtual_machine.this[0].name
}

output "private_ip_address" {
  description = "The primary private IP address of the VM"
  value       = azurerm_network_interface.this.private_ip_address
}

output "network_interface_id" {
  description = "The ID of the network interface"
  value       = azurerm_network_interface.this.id
}

output "identity" {
  description = "The managed identity of the VM"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].identity : azurerm_windows_virtual_machine.this[0].identity
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = var.identity_type != null && (var.identity_type == "SystemAssigned" || var.identity_type == "SystemAssigned, UserAssigned") ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].identity[0].principal_id : azurerm_windows_virtual_machine.this[0].identity[0].principal_id) : null
}

output "data_disk_ids" {
  description = "Map of data disk names to their IDs"
  value       = { for k, v in azurerm_managed_disk.this : k => v.id }
}

output "computer_name" {
  description = "The computer name of the VM"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine.this[0].computer_name : azurerm_windows_virtual_machine.this[0].computer_name
}

output "zone" {
  description = "The availability zone of the VM"
  value       = var.zone
}
