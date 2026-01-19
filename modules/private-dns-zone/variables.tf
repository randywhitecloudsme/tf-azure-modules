variable "name" {
  description = "The name of the Private DNS Zone"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$", var.name))
    error_message = "Private DNS Zone name must be a valid domain name."
  }
}

variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
}

variable "tags" {
  description = "Tags to apply to the Private DNS Zone"
  type        = map(string)
  default     = {}
}

# SOA Record
variable "soa_record" {
  description = "SOA record configuration"
  type = object({
    email        = string
    expire_time  = optional(number)
    minimum_ttl  = optional(number)
    refresh_time = optional(number)
    retry_time   = optional(number)
    ttl          = optional(number)
  })
  default = null

  validation {
    condition = var.soa_record == null || (
      can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", var.soa_record.email))
    )
    error_message = "SOA email must be a valid email address."
  }
}

# Virtual Network Links
variable "virtual_network_links" {
  description = "Map of virtual network links"
  type = map(object({
    name                 = string
    virtual_network_id   = string
    registration_enabled = optional(bool)
  }))
  default = {}
}

# A Records
variable "a_records" {
  description = "Map of A records"
  type = map(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.a_records : (
        alltrue([for ip in record.records : can(regex("^(?:[0-9]{1,3}\\.){3}[0-9]{1,3}$", ip))])
      )
    ])
    error_message = "A records must contain valid IPv4 addresses."
  }

  validation {
    condition = alltrue([
      for record in var.a_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

# AAAA Records
variable "aaaa_records" {
  description = "Map of AAAA records"
  type = map(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.aaaa_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

# CNAME Records
variable "cname_records" {
  description = "Map of CNAME records"
  type = map(object({
    name   = string
    ttl    = number
    record = string
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.cname_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

# MX Records
variable "mx_records" {
  description = "Map of MX records"
  type = map(object({
    name = string
    ttl  = number
    records = list(object({
      preference = number
      exchange   = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.mx_records : (
        alltrue([for mx in record.records : mx.preference >= 0 && mx.preference <= 65535])
      )
    ])
    error_message = "MX preference must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for record in var.mx_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

# PTR Records
variable "ptr_records" {
  description = "Map of PTR records"
  type = map(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.ptr_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

# SRV Records
variable "srv_records" {
  description = "Map of SRV records"
  type = map(object({
    name = string
    ttl  = number
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.srv_records : (
        alltrue([
          for srv in record.records : (
            srv.priority >= 0 && srv.priority <= 65535 &&
            srv.weight >= 0 && srv.weight <= 65535 &&
            srv.port >= 0 && srv.port <= 65535
          )
        ])
      )
    ])
    error_message = "SRV priority, weight, and port must be between 0 and 65535."
  }

  validation {
    condition = alltrue([
      for record in var.srv_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }
}

# TXT Records
variable "txt_records" {
  description = "Map of TXT records"
  type = map(object({
    name    = string
    ttl     = number
    records = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in var.txt_records : (
        record.ttl >= 1 && record.ttl <= 2147483647
      )
    ])
    error_message = "TTL must be between 1 and 2147483647 seconds."
  }

  validation {
    condition = alltrue([
      for record in var.txt_records : (
        alltrue([for txt in record.records : length(txt) <= 1024])
      )
    ])
    error_message = "TXT record values must not exceed 1024 characters."
  }
}
