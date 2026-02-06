# Active Directory Domain Services (Entra DS)

 This terraform module simplifies the creation and management of azure active directory domain services resources, providing customizable options for domain configuration, replica sets, forest trusts, and security settings, all managed through code.

## Features

Capability to deploy managed domain controllers.

Includes support for replica sets across multiple regions for high availability.

Supports forest trusts with on-premises Active Directory domains.

Configurable security settings including NTLM, Kerberos, and TLS options.

Notification support for domain administrators and global administrators.

Secure LDAP configuration capabilities.

Utilization of terratest for robust validation.

<!-- BEGIN_TF_DOCS -->
## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (~> 1.0)

- <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) (~> 3.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.0)

## Providers

The following providers are used by this module:

- <a name="provider_azuread"></a> [azuread](#provider\_azuread) (~> 3.0)

- <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) (~> 4.0)

## Resources

The following resources are used by this module:

- [azuread_service_principal.aadds](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) (resource)
- [azurerm_active_directory_domain_service.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service) (resource)
- [azurerm_active_directory_domain_service_replica_set.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service_replica_set) (resource)
- [azurerm_active_directory_domain_service_trust.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/active_directory_domain_service_trust) (resource)

## Required Inputs

The following input variables are required:

### <a name="input_config"></a> [config](#input\_config)

Description: contains domain service configuration

Type:

```hcl
object({
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
```

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_tags"></a> [tags](#input\_tags)

Description: tags to be added to the resources

Type: `map(string)`

Default: `{}`

## Outputs

The following outputs are exported:

### <a name="output_domain_service"></a> [domain\_service](#output\_domain\_service)

Description: contains all domain service configuration

### <a name="output_replica_sets"></a> [replica\_sets](#output\_replica\_sets)

Description: contains all replica sets

### <a name="output_trusts"></a> [trusts](#output\_trusts)

Description: contains all domain trusts
<!-- END_TF_DOCS -->

## Goals

For more information, please see our [goals and non-goals](./GOALS.md).

## Testing

For more information, please see our testing [guidelines](./TESTING.md)

## Notes

Using a dedicated module, we've developed a naming convention for resources that's based on specific regular expressions for each type, ensuring correct abbreviations and offering flexibility with multiple prefixes and suffixes.

Full examples detailing all usages, along with integrations with dependency modules, are located in the examples directory.

To update the module's documentation run `make doc`

## Authors

Module is maintained by [these awesome contributors](https://github.com/cloudnationhq/terraform-azure-entra-ds/graphs/contributors).

## Contributors

We welcome contributions from the community! Whether it's reporting a bug, suggesting a new feature, or submitting a pull request, your input is highly valued.

For more information, please see our contribution [guidelines](./CONTRIBUTING.md). <br><br>

<a href="https://github.com/cloudnationhq/terraform-azure-entra-ds/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=cloudnationhq/terraform-azure-entra-ds" />
</a>

## License

MIT Licensed. See [LICENSE](./LICENSE) for full details.

## References

- [Documentation](https://learn.microsoft.com/en-us/entra/identity/domain-services/)
- [Rest Api](https://learn.microsoft.com/en-us/rest/api/activedirectory/)
- [Rest Api Specs](https://github.com/Azure/azure-rest-api-specs/tree/main/specification/domainservices)
