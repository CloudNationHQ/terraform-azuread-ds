variable "domain_service" {
  description = "contains domain service configuration"
  type = object({
    name                      = string
    resource_group_name       = optional(string)
    location                  = optional(string)
    domain_name               = string
    domain_configuration_type = optional(string)
    sku                       = optional(string, "Standard")
    filtered_sync_enabled     = optional(bool, false)
    tags                      = optional(map(string))

    service_principal = optional(object({
      use_existing = optional(bool, false)
      other_cloud  = optional(bool, false)

      account_enabled               = optional(bool)
      alternative_names             = optional(set(string))
      app_role_assignment_required  = optional(bool)
      description                   = optional(string)
      login_url                     = optional(string)
      notes                         = optional(string)
      notification_email_addresses  = optional(set(string))
      owners                        = optional(set(string))
      preferred_single_sign_on_mode = optional(string)
      tags                          = optional(set(string))

      feature_tags = optional(object({
        custom_single_sign_on = optional(bool)
        enterprise            = optional(bool)
        gallery               = optional(bool)
        hide                  = optional(bool)
      }))

      # deprecated by the azuread provider, use feature_tags instead
      features = optional(object({
        custom_single_sign_on_app = optional(bool)
        enterprise_application    = optional(bool)
        gallery_application       = optional(bool)
        visible_to_users          = optional(bool)
      }))

      saml_single_sign_on = optional(object({
        relay_state = optional(string)
      }))
    }))

    initial_replica_set = object({
      subnet_id = string
    })

    notifications = optional(object({
      additional_recipients = optional(list(string), [])
      notify_dc_admins      = optional(bool)
      notify_global_admins  = optional(bool)
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

  validation {
    condition = (
      try(var.domain_service.service_principal, null) == null ? true : length([
        for v in [
          var.domain_service.service_principal.tags,
          var.domain_service.service_principal.feature_tags,
          var.domain_service.service_principal.features
        ] : v if v != null
      ]) <= 1
    )
    error_message = "service_principal.tags, service_principal.feature_tags and service_principal.features are mutually exclusive, set at most one."
  }

  validation {
    condition     = lookup(var.domain_service, "location", null) != null || var.location != null
    error_message = "location must be set on var.domain_service.location or on the module-level var.location."
  }

  validation {
    condition     = lookup(var.domain_service, "resource_group_name", null) != null || var.resource_group_name != null
    error_message = "resource_group_name must be set on var.domain_service.resource_group_name or on the module-level var.resource_group_name."
  }
}

variable "location" {
  description = "default azure region to be used."
  type        = string
  default     = null
}

variable "resource_group_name" {
  description = "default resource group to be used."
  type        = string
  default     = null
}

variable "tags" {
  description = "tags to be added to the resources"
  type        = map(string)
  default     = {}
}
