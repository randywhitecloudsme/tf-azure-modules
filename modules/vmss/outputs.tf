output "id" {
  description = "The ID of the virtual machine scale set"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].id : azurerm_windows_virtual_machine_scale_set.this[0].id
}

output "name" {
  description = "The name of the virtual machine scale set"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].name : azurerm_windows_virtual_machine_scale_set.this[0].name
}

output "unique_id" {
  description = "The unique ID of the virtual machine scale set"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].unique_id : azurerm_windows_virtual_machine_scale_set.this[0].unique_id
}

output "identity" {
  description = "The managed identity of the VMSS"
  value       = var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].identity : azurerm_windows_virtual_machine_scale_set.this[0].identity
}

output "principal_id" {
  description = "The principal ID of the system-assigned managed identity"
  value       = var.identity_type != null && (var.identity_type == "SystemAssigned" || var.identity_type == "SystemAssigned, UserAssigned") ? (var.os_type == "Linux" ? azurerm_linux_virtual_machine_scale_set.this[0].identity[0].principal_id : azurerm_windows_virtual_machine_scale_set.this[0].identity[0].principal_id) : null
}

output "autoscale_setting_id" {
  description = "The ID of the autoscale setting"
  value       = var.enable_autoscaling ? azurerm_monitor_autoscale_setting.this[0].id : null
}
