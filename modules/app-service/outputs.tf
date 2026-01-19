output "service_plan_id" {
  description = "The ID of the Service Plan"
  value       = azurerm_service_plan.this.id
}

output "service_plan_name" {
  description = "The name of the Service Plan"
  value       = azurerm_service_plan.this.name
}

output "app_service_id" {
  description = "The ID of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].id : azurerm_windows_web_app.this[0].id
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].name : azurerm_windows_web_app.this[0].name
}

output "default_hostname" {
  description = "The default hostname of the App Service"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].default_hostname : azurerm_windows_web_app.this[0].default_hostname
}

output "outbound_ip_addresses" {
  description = "A comma separated list of outbound IP addresses"
  value       = var.os_type == "Linux" ? azurerm_linux_web_app.this[0].outbound_ip_addresses : azurerm_windows_web_app.this[0].outbound_ip_addresses
}
