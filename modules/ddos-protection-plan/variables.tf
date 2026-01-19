variable "name" {
  description = "The name of the DDoS Protection Plan"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9][a-zA-Z0-9_.-]{0,78}[a-zA-Z0-9_]$", var.name))
    error_message = "DDoS Protection Plan name must be 1-80 characters, start with alphanumeric, and contain only alphanumerics, underscores, periods, and hyphens."
  }
}

variable "location" {
  description = "The Azure region where the DDoS Protection Plan will be created"
  type        = string
}

variable "resource_group_name" {
  description = "The name of the resource group in which to create the DDoS Protection Plan"
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resource"
  type        = map(string)
  default     = {}
}
