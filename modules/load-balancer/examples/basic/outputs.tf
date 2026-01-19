output "load_balancer_id" {
  description = "The ID of the load balancer"
  value       = module.lb_basic.load_balancer_id
}

output "public_ip_address" {
  description = "The public IP address"
  value       = module.lb_basic.public_ip_address
}
