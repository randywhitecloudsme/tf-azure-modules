variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default     = "example-aks-rg"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default     = "eastus"
}

variable "aks_cluster_name" {
  description = "The name of the AKS cluster"
  type        = string
  default     = "example-aks-cluster"
}

variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "exampleaks"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = null
}

variable "default_node_pool" {
  description = "Default node pool configuration"
  type = object({
    name                = string
    vm_size             = string
    node_count          = optional(number)
    enable_auto_scaling = optional(bool, false)
    min_count           = optional(number)
    max_count           = optional(number)
    max_pods            = optional(number)
    os_disk_size_gb     = optional(number)
    vnet_subnet_id      = optional(string)
    zones               = optional(list(string))
  })
  default = {
    name       = "default"
    vm_size    = "Standard_D2_v2"
    node_count = 2
  }
}

variable "network_profile" {
  description = "Network profile configuration"
  type = object({
    network_plugin    = string
    network_policy    = optional(string)
    dns_service_ip    = optional(string)
    service_cidr      = optional(string)
    load_balancer_sku = optional(string, "standard")
  })
  default = {
    network_plugin = "azure"
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "Development"
    ManagedBy   = "Terraform"
  }
}
