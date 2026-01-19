output "firewall_id" {
  description = "The ID of the firewall"
  value       = module.firewall_basic.firewall_id
}

output "firewall_private_ip" {
  description = "The private IP address"
  value       = module.firewall_basic.firewall_private_ip
}
