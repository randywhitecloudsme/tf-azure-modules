variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "gateway_subnet_id" {
  description = "The ID of the GatewaySubnet"
  type        = string
}

variable "onprem_gateway_ip" {
  description = "The on-premises VPN gateway public IP"
  type        = string
}

variable "onprem_address_space" {
  description = "The on-premises address space"
  type        = list(string)
  default     = ["192.168.0.0/16"]
}

variable "shared_key" {
  description = "The shared key for the VPN connection"
  type        = string
  sensitive   = true
}
