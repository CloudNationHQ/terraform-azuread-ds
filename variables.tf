variable "config" {
  description = "contains domain service configuration"
  type = object({
    name                      = string
    resource_group_name       = string
    location                  = string
    domain_name               = string
    domain_configuration_type = optional(string)
    sku                       = optional(string, "Standard")
    filtered_sync_enabled     = optional(bool, false)
    tags                      = optional(map(string))

    service_principal = optional(object({
      use_existing = optional(bool, false)
      other_cloud  = optional(bool, false)
    }))

    initial_replica_set = object({
      subnet_id = string
    })

    notifications = optional(object({
      additional_recipients = optional(list(string), [])
      notify_dc_admins      = optional(bool, true)
      notify_global_admins  = optional(bool, true)
    }))

    secure_ldap = optional(object({
      enabled                  = bool
      pfx_certificate          = string
      pfx_certificate_password = string
      external_access_enabled  = optional(bool, false)
    }))

    security = optional(object({
      sync_kerberos_passwords         = optional(bool, false)
      sync_ntlm_passwords             = optional(bool, false)
      sync_on_prem_passwords          = optional(bool, false)
      ntlm_v1_enabled                 = optional(bool, false)
      tls_v1_enabled                  = optional(bool, false)
      kerberos_rc4_encryption_enabled = optional(bool, false)
      kerberos_armoring_enabled       = optional(bool, false)
    }))

    replica_sets = optional(map(object({
      location  = string
      subnet_id = string
    })), {})

    trusts = optional(map(object({
      name                   = optional(string)
      trusted_domain_fqdn    = string
      trusted_domain_dns_ips = list(string)
      password               = string
    })), {})
  })
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
