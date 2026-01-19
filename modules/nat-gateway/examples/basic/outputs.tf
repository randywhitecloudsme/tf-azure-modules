output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = module.nat_gateway_basic.nat_gateway_id
}

output "public_ip_addresses" {
  description = "List of public IP addresses"
  value       = module.nat_gateway_basic.public_ip_addresses
}
