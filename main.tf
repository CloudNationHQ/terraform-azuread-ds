# Azure AD Domain Services service principal
resource "azuread_service_principal" "aadds" {
  client_id    = try(var.config.service_principal.other_cloud, false) != false ? "2565bd9d-da50-47d4-8b85-4c97f669dc36" : "6ba9a5d4-8456-4118-b521-9c5ca10cdf84"
  use_existing = try(var.config.service_principal.use_existing, false) != false ? true : false
}

# domain service
resource "azurerm_active_directory_domain_service" "this" {
  depends_on = [azuread_service_principal.aadds]

  name                      = var.config.name
  location                  = var.config.location
  resource_group_name       = var.config.resource_group_name
  domain_name               = var.config.domain_name
  sku                       = var.config.sku
  filtered_sync_enabled     = var.config.filtered_sync_enabled
  domain_configuration_type = var.config.domain_configuration_type

  initial_replica_set {
    subnet_id = var.config.initial_replica_set.subnet_id
  }

  dynamic "notifications" {
    for_each = try(var.config.notifications, null) != null ? [var.config.notifications] : []

    content {
      additional_recipients = notifications.value.additional_recipients
      notify_dc_admins      = notifications.value.notify_dc_admins
      notify_global_admins  = notifications.value.notify_global_admins
    }
  }

  dynamic "secure_ldap" {
    for_each = try(var.config.secure_ldap, null) != null ? [var.config.secure_ldap] : []

    content {
      enabled                  = secure_ldap.value.enabled
      pfx_certificate          = secure_ldap.value.pfx_certificate
      pfx_certificate_password = secure_ldap.value.pfx_certificate_password
      external_access_enabled  = secure_ldap.value.external_access_enabled
    }
  }

  dynamic "security" {
    for_each = try(var.config.security, null) != null ? [var.config.security] : []

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

  tags = coalesce(var.config.tags, var.tags)
}

# replica sets
resource "azurerm_active_directory_domain_service_replica_set" "this" {
  for_each = lookup(var.config, "replica_sets", {})

  domain_service_id = azurerm_active_directory_domain_service.this.id
  location          = coalesce(lookup(each.value, "location", null), azurerm_active_directory_domain_service.this.location)
  subnet_id         = each.value.subnet_id
}

# trusts
resource "azurerm_active_directory_domain_service_trust" "this" {
  for_each = lookup(var.config, "trusts", {})

  name                   = coalesce(each.value.name, each.key)
  domain_service_id      = azurerm_active_directory_domain_service.this.id
  trusted_domain_fqdn    = each.value.trusted_domain_fqdn
  trusted_domain_dns_ips = each.value.trusted_domain_dns_ips
  password               = each.value.password
}

