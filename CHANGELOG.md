# Changelog

## [1.1.0](https://github.com/CloudNationHQ/terraform-azuread-ds/compare/v1.0.0...v1.1.0) (2026-02-06)


### Features

* update app id for other Azure Clouds (e.g. US Gov) ([#3](https://github.com/CloudNationHQ/terraform-azuread-ds/issues/3)) ([512a12c](https://github.com/CloudNationHQ/terraform-azuread-ds/commit/512a12c4417c08c776c00902f8330aca727ab25f))

## 1.0.0 (2026-02-03)


### Features

* add initial resources ([45d41a4](https://github.com/CloudNationHQ/terraform-azuread-ds/commit/45d41a42f067f7151d6118b3a9042fab51044d24))
* add initial resources ([649e959](https://github.com/CloudNationHQ/terraform-azuread-ds/commit/649e959e6585ddfc6472aa975bd7d213e40cbccf))
* update make docs ([44a732a](https://github.com/CloudNationHQ/terraform-azuread-ds/commit/44a732a4aa29fa56a489e093bbfa312d8a840816))

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
