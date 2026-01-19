output "standard_public_ip_id" {
  description = "The ID of the Standard public IP"
  value       = module.public_ip_standard.public_ip_id
}

output "standard_public_ip_address" {
  description = "The Standard public IP address"
  value       = module.public_ip_standard.public_ip_address
}

output "standard_fqdn" {
  description = "The FQDN of the Standard public IP"
  value       = module.public_ip_standard.fqdn
}

output "basic_public_ip_id" {
  description = "The ID of the Basic public IP"
  value       = module.public_ip_basic.public_ip_id
}

output "basic_public_ip_address" {
  description = "The Basic public IP address (may be empty if not attached)"
  value       = module.public_ip_basic.public_ip_address
}
