output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone"
  value       = module.private_dns_zone_basic.private_dns_zone_id
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS Zone"
  value       = module.private_dns_zone_basic.private_dns_zone_name
}
