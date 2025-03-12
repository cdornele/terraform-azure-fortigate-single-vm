#--------------------------------------------*--------------------------------------------
#  Main Example: Fortigate Single VM - Main
#--------------------------------------------*--------------------------------------------

provider "azurerm" {
  features {}
}

module "resource_group-fgt" {
  source   = "cdornele/resource-group/azure"
  version  = "1.0.0"
  stack    = "fortigate"
  suffixes = ["t", "01"]
  location = "eastus"
  tags = {
    "environement" = "test"
    "owner"        = "example"
    "project"      = "example"
    "customer"     = "example"
  }
}

module "resource_group-conn" {
  source   = "cdornele/resource-group/azure"
  version  = "1.0.0"
  stack    = "connectivity"
  suffixes = ["t", "01"]
  location = "eastus"
  tags = {
    "environement" = "test"
    "owner"        = "example"
    "project"      = "example"
    "customer"     = "example"
  }
}

module "network" {
  source  = "cdornele/network-spoke/azure"
  version = "2.0.2"
  global_settings = {
    name     = "conn"
    suffixes = ["t", "01"]
  }
  settings = {

    address_space       = ["192.168.0.0/24"]
    dns_servers_enabled = true
    dns_servers_list    = ["8.8.8.8", "1.1.1.1"]
    subnet_settings = {
      subnets = {
        untrust = {
          name             = "untrust"
          suffixes         = ["t", "01"]
          address_prefixes = ["192.168.0.0/28"]
          nsg_key          = "untrust-nsg"
          rts_key          = "untrust-rts"
        }
        trust = {
          name             = "trust"
          suffixes         = ["t", "01"]
          address_prefixes = ["192.168.0.16/28"]
          nsg_key          = "trust-nsg"
          rts_key          = "trust-rts"
        }
      }
    }
    network_security_group_settings = {
      empty_nsg = {}
      trust-nsg = {
        name     = "trust"
        suffixes = ["t", "01"]
        tags = {
          nsg_definition = "trust_nsg"
        }
        rules = [
          {
            name                       = "trust-inbound-rule-allow",
            priority                   = "100"
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "*"
            source_port_range          = "*"
            destination_port_range     = "*"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
            description                = "Allow ingress traffic"
          },
          {
            name                       = "trust-outbound-rule-allow",
            priority                   = "100"
            direction                  = "Outbound"
            access                     = "Allow"
            protocol                   = "*"
            source_port_range          = "*"
            destination_port_range     = "*"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
            description                = "Allow egress traffic"
          }
        ]
      }
      untrust-nsg = {
        name     = "untrust"
        suffixes = ["t", "01"]
        tags = {
          nsg_definition = "untrust_nsg"
        }
        rules = [
          {
            name                       = "untrust-inbound-rule-allow",
            priority                   = "100"
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "*"
            source_port_range          = "*"
            destination_port_range     = "*"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
            description                = "Allow ingress traffic"
          },
          {
            name                       = "untrust-outbound-rule-allow",
            priority                   = "100"
            direction                  = "Outbound"
            access                     = "Allow"
            protocol                   = "*"
            source_port_range          = "*"
            destination_port_range     = "*"
            source_address_prefix      = "*"
            destination_address_prefix = "*"
            description                = "Allow egress traffic"
          }
        ]
      }

    }
    route_tables_settings = {
      trust-rts = {
        is_Enabled = true
        name       = "trust"
        suffixes   = ["t", "01"]
      }
      untrust-rts = {
        is_Enabled = true
        name       = "untrust"
        suffixes   = ["t", "01"]
      }
    }

  }
  resource_group = module.resource_group-conn.name
  location       = module.resource_group-conn.location
  tags = {
    "environement" = "test"
    "owner"        = "example"
    "project"      = "example"
    "customer"     = "example"
  }
}

module "fortigate" {
  source                     = "../.."
  resource_group_name        = module.resource_group-fgt.name
  location                   = module.resource_group-fgt.location
  fortinet_untrust_subnet_id = module.network.subnets[0].untrust.subnet_id
  fortinet_trust_subnet_id   = module.network.subnets[0].trust.subnet_id
  fortinet_vm_username       = "exampleadmin"
  fortinet_vm_password       = "Password1234!"
  fortinet_prefix            = "fgt"
  fortinet_settings = { accept_agreement = false
    fortigate_vm_size = "Standard_F2"
    fortigate_vm_name = "FGT-VM"
    publisher_id      = "fortinet"
    offer_id          = "fortinet_fortigate-vm_v5"
    license_type      = "payg"
    sku_id = {
      byol = "fortinet_fg-vm"
      payg = "fortinet_fg-vm_payg_2023"
    }
    version                          = "7.6.0"
    admin_port                       = "8443"
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true
    disable_password_authentication  = false
    publicip_name                    = "pip-fgt"
    network = {
      untrust_ip      = "192.168.0.4"
      untrust_netmask = "255.255.255.240"
      untrust_gateway = "192.168.0.1"
      trust_ip        = "192.168.0.20"
      trust_netmask   = "255.255.255.240"
    }
  }
  tags = {
    "environement" = "test"
    "owner"        = "example"
    "project"      = "example"
    "customer"     = "example"
  }
}

output "fortigate_public_ip" {
  description = "value of the fortigate public ip"
  value = module.fortigate.fortigate_untrust_public_ip
}

output "fortigate_admin_port" {
  description = "value of the fortigate admin port"
  value = module.fortigate.fortigate_admin_port
}

# end
#--------------------------------------------*--------------------------------------------