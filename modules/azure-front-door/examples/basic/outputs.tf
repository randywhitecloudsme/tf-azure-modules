output "front_door_id" {
  description = "The ID of the Front Door profile"
  value       = module.front_door.front_door_id
}

output "front_door_name" {
  description = "The name of the Front Door profile"
  value       = module.front_door.front_door_name
}

output "endpoint_host_names" {
  description = "Map of endpoint host names"
  value       = module.front_door.endpoint_host_names
}

output "endpoint_url" {
  description = "The URL to access the Front Door endpoint"
  value       = "https://${module.front_door.endpoint_host_names["example-endpoint"]}"
}
