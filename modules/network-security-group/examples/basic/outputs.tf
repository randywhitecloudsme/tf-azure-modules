output "nsg_id" {
  description = "The ID of the NSG"
  value       = module.nsg_basic.nsg_id
}

output "nsg_name" {
  description = "The name of the NSG"
  value       = module.nsg_basic.nsg_name
}
