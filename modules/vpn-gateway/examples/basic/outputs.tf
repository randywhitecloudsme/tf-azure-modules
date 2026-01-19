output "vpn_gateway_id" {
  description = "The ID of the VPN Gateway"
  value       = module.vpn_gateway_basic.vpn_gateway_id
}

output "public_ip_addresses" {
  description = "List of public IP addresses"
  value       = module.vpn_gateway_basic.public_ip_addresses
}
