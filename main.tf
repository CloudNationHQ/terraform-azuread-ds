# service principal
resource "azuread_service_principal" "this" {
  client_id    = try(var.domain_service.service_principal.other_cloud, false) == false ? "2565bd9d-da50-47d4-8b85-4c97f669dc36" : "6ba9a5d4-8456-4118-b521-9c5ca10cdf84"
  use_existing = try(var.domain_service.service_principal.use_existing, false) != false ? true : false

  account_enabled               = try(var.domain_service.service_principal.account_enabled, null)
  alternative_names             = try(var.domain_service.service_principal.alternative_names, null)
  app_role_assignment_required  = try(var.domain_service.service_principal.app_role_assignment_required, null)
  description                   = try(var.domain_service.service_principal.description, null)
  login_url                     = try(var.domain_service.service_principal.login_url, null)
  notes                         = try(var.domain_service.service_principal.notes, null)
  notification_email_addresses  = try(var.domain_service.service_principal.notification_email_addresses, null)
  owners                        = try(var.domain_service.service_principal.owners, null)
  preferred_single_sign_on_mode = try(var.domain_service.service_principal.preferred_single_sign_on_mode, null)
  tags                          = try(var.domain_service.service_principal.tags, null)

  dynamic "feature_tags" {
    for_each = try(var.domain_service.service_principal.feature_tags, null) != null ? { "this" = var.domain_service.service_principal.feature_tags } : {}

    content {
      custom_single_sign_on = feature_tags.value.custom_single_sign_on
      enterprise            = feature_tags.value.enterprise
      gallery               = feature_tags.value.gallery
      hide                  = feature_tags.value.hide
    }
  }

  dynamic "saml_single_sign_on" {
    for_each = try(var.domain_service.service_principal.saml_single_sign_on, null) != null ? { "this" = var.domain_service.service_principal.saml_single_sign_on } : {}

    content {
      relay_state = saml_single_sign_on.value.relay_state
    }
  }
}

# domain service
resource "azurerm_active_directory_domain_service" "this" {
  # no attribute reference to the service principal exists, but Azure requires it before the domain service can be created
  depends_on = [azuread_service_principal.this]

  resource_group_name = coalesce(
    var.domain_service.resource_group_name, var.resource_group_name
  )

  location = coalesce(
    var.domain_service.location, var.location
  )

  tags = coalesce(
    var.domain_service.tags, var.tags
  )

  name                      = var.domain_service.name
  domain_name               = var.domain_service.domain_name
  sku                       = var.domain_service.sku
  filtered_sync_enabled     = var.domain_service.filtered_sync_enabled
  domain_configuration_type = var.domain_service.domain_configuration_type

  initial_replica_set {
    subnet_id = var.domain_service.initial_replica_set.subnet_id
  }

  dynamic "notifications" {
    for_each = var.domain_service.notifications != null ? { "this" = var.domain_service.notifications } : {}

    content {
      additional_recipients = notifications.value.additional_recipients
      notify_dc_admins      = notifications.value.notify_dc_admins
      notify_global_admins  = notifications.value.notify_global_admins
    }
  }

  dynamic "secure_ldap" {
    for_each = var.domain_service.secure_ldap != null ? { "this" = var.domain_service.secure_ldap } : {}

    content {
      enabled                  = secure_ldap.value.enabled
      pfx_certificate          = secure_ldap.value.pfx_certificate
      pfx_certificate_password = secure_ldap.value.pfx_certificate_password
      external_access_enabled  = secure_ldap.value.external_access_enabled
    }
  }

  dynamic "security" {
    for_each = var.domain_service.security != null ? { "this" = var.domain_service.security } : {}

    content {
      sync_kerberos_passwords         = security.value.sync_kerberos_passwords
      sync_ntlm_passwords             = security.value.sync_ntlm_passwords
      sync_on_prem_passwords          = security.value.sync_on_prem_passwords
      ntlm_v1_enabled                 = security.value.ntlm_v1_enabled
      tls_v1_enabled                  = security.value.tls_v1_enabled
      kerberos_rc4_encryption_enabled = security.value.kerberos_rc4_encryption_enabled
      kerberos_armoring_enabled       = security.value.kerberos_armoring_enabled
    }
  }
}

# replica sets
resource "azurerm_active_directory_domain_service_replica_set" "this" {
  for_each = var.domain_service.replica_sets

  domain_service_id = azurerm_active_directory_domain_service.this.id
  location          = coalesce(each.value.location, azurerm_active_directory_domain_service.this.location)
  subnet_id         = each.value.subnet_id
}

# trusts
resource "azurerm_active_directory_domain_service_trust" "this" {
  for_each = var.domain_service.trusts

  name                   = coalesce(each.value.name, each.key)
  domain_service_id      = azurerm_active_directory_domain_service.this.id
  trusted_domain_fqdn    = each.value.trusted_domain_fqdn
  trusted_domain_dns_ips = each.value.trusted_domain_dns_ips
  password               = each.value.password
}
