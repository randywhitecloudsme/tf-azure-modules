output "app_service_url" {
  description = "The default URL of the App Service"
  value       = "https://${module.app_service.default_hostname}"
}

output "app_service_id" {
  description = "The ID of the App Service"
  value       = module.app_service.app_service_id
}
