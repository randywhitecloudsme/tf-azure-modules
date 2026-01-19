output "ase_id" {
  description = "The ID of the App Service Environment"
  value       = module.ase.id
}

output "ase_name" {
  description = "The name of the App Service Environment"
  value       = module.ase.name
}

output "ase_dns_suffix" {
  description = "The DNS suffix for the ASE"
  value       = module.ase.dns_suffix
}

output "ase_internal_ip" {
  description = "The internal IP addresses"
  value       = module.ase.internal_inbound_ip_addresses
}

output "private_dns_zone_name" {
  description = "The private DNS zone name"
  value       = module.ase.private_dns_zone_name
}
