# Changelog

## [1.0.0] - 2026-01-05

### Added

- Initial release of the Azure Active Directory Domain Services (Entra DS) module
- Support for `azurerm_active_directory_domain_service` resource
- Support for `azurerm_active_directory_domain_service_replica_set` resource for high availability across regions
- Support for `azurerm_active_directory_domain_service_trust` resource for forest trusts with on-premises AD
- Comprehensive variable structure with validation rules
- Security configuration options (NTLM, Kerberos, TLS settings)
- Notification configuration support
- Secure LDAP configuration capabilities
- Usage example:
  - Default: Basic domain service setup
- Terratest integration for automated testing
