# import {
#   to = module.domain_service.azurerm_active_directory_domain_service.this
#   id = "/subscriptions/eb325ab2-9ad8-4e29-abd1-00876fdd6101/resourceGroups/rg-demo-dev-qfuj/providers/Microsoft.AAD/domainServices/aadds-demo-dev/initialReplicaSetId/2e6c70d9-de32-4e5c-9adb-492150d493ea"
# }

# import {
#   to = module.network.azurerm_virtual_network.vnet["vnet"]
#   id = "/subscriptions/eb325ab2-9ad8-4e29-abd1-00876fdd6101/resourceGroups/rg-demo-dev-qfuj/providers/Microsoft.Network/virtualNetworks/vnet-demo-dev"
# }

module "naming" {
  source  = "cloudnationhq/naming/azure"
  version = "~> 0.24"

  suffix = ["demo", "dev"]
}

module "rg" {
  source  = "cloudnationhq/rg/azure"
  version = "~> 2.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = "westeurope"
    }
  }
}

module "network" {
  source  = "cloudnationhq/vnet/azure"
  version = "~> 9.0"

  naming = local.naming

  vnet = {
    name                = module.naming.virtual_network.name
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name
    address_space       = ["10.0.0.0/16"]
    dns_servers         = ["10.0.1.4", "10.0.1.5"]

    subnets = {
      aadds = {
        address_prefixes = ["10.0.1.0/24"]
        network_security_group = {
          name = "${module.naming.network_security_group.name}-aadds"
          rules = {
            AllowSyncWithAzureAD = {
              priority                   = 100
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "443"
              source_address_prefix      = "AzureActiveDirectoryDomainServices"
              destination_address_prefix = "*"
            }
            AllowPSRemoting = {
              priority                   = 200
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "5986"
              source_address_prefix      = "AzureActiveDirectoryDomainServices"
              destination_address_prefix = "*"
            }
            AllowRD = {
              priority                   = 201
              direction                  = "Inbound"
              access                     = "Allow"
              protocol                   = "Tcp"
              source_port_range          = "*"
              destination_port_range     = "3389"
              source_address_prefix      = "CorpNetSaw"
              destination_address_prefix = "*"
            }
          }
        }
      }
    }
  }
}

data "azuread_client_config" "current" {}

module "groups" {
  source  = "cloudnationhq/groups/azuread"
  version = "~> 1.0"

  groups = {
    aad_dc_admins = {
      display_name  = "AAD DC Administrators"
      description   = "Delegated group to administer Microsoft Entra Domain Services"
      mail_enabled  = false
      mail_nickname = "AADDCAdministrators"
      members       = [data.azuread_client_config.current.object_id]
    }
  }
}

module "domain_service" {
  source = "../.."

  config = {
    name                      = "aadds-demo-dev"
    location                  = module.rg.groups.demo.location
    resource_group_name       = module.rg.groups.demo.name
    domain_name               = "example.com"
    sku                       = "Standard"
    domain_configuration_type = "FullySynced"

    initial_replica_set = {
      subnet_id = module.network.subnets.aadds.id
    }

    service_principal = {
      use_existing = false
    }

    notifications = {
      notify_dc_admins     = true
      notify_global_admins = true
    }

    security = {
      tls_v1_enabled          = false
      sync_kerberos_passwords = true
    }
  }
}
