output "application_gateway_id" {
  description = "The ID of the application gateway"
  value       = module.app_gateway_basic.application_gateway_id
}

output "public_ip_address" {
  description = "The public IP address"
  value       = module.app_gateway_basic.public_ip_address
}
