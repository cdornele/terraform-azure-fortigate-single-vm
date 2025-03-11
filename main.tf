#--------------------------------------------*--------------------------------------------
#  Module: Fortigate - Single VM - Main
#--------------------------------------------*--------------------------------------------
resource "random_id" "this" {
  keepers = {
    resource_group = var.resource_group_name
  }
  byte_length = 3
}

resource "azurerm_storage_account" "this" {
  name                      = format("%s%s%s","stdiag", var.fortinet_prefix, random_id.this.hex)
  resource_group_name       = var.resource_group_name
  location                  = var.location
  account_replication_type  = "LRS"
  account_tier              = "Standard"
  account_kind              = "StorageV2"
  access_tier               = "Cool"    
  min_tls_version           = "TLS1_2"      
  tags                      = var.tags
}
resource "azurerm_marketplace_agreement" "this" {
  count                    = lookup(var.fortinet_settings, "accept_agreement", true) ? 1 : 0
  publisher                = lookup(var.fortinet_settings, "publisher_id", null)
  offer                    = lookup(var.fortinet_settings, "offer_id", null)
  plan                     = lookup(var.fortinet_settings, "license_type", "payg") == "payg" ? try(var.fortinet_settings.sku_id["payg"], null) : try(var.fortinet_settings.sku_id["byol"], null)
}

resource "azurerm_virtual_machine" "fgt-vm" {
  depends_on                          = [ 
                                        azurerm_network_interface.fgt_untrust_port1,
                                        azurerm_network_interface.fgt_trust_port2,
                                        azurerm_marketplace_agreement.this,
                                        azurerm_storage_account.this
   ]
  name                                = var.fortinet_settings.fortigate_vm_name
  location                            = var.location
  resource_group_name                 = var.resource_group_name
  tags                                = var.tags
  network_interface_ids               = [
                                          azurerm_network_interface.fgt_untrust_port1.id,
                                          azurerm_network_interface.fgt_trust_port2.id,
                                        ]
  primary_network_interface_id        = azurerm_network_interface.fgt_untrust_port1.id
  vm_size                             = var.fortinet_settings.fortigate_vm_size
  delete_os_disk_on_termination       = lookup(var.fortinet_settings, "delete_os_disk_on_termination", false)
  delete_data_disks_on_termination    = lookup(var.fortinet_settings, "delete_data_disks_on_termination", false)

  storage_image_reference {
    publisher                         = lookup(var.fortinet_settings, "publisher_id", null)
    offer                             = lookup(var.fortinet_settings, "offer_id", null)
    sku                               = lookup(var.fortinet_settings, "license_type", "payg") == "payg" ? try(var.fortinet_settings.sku_id["payg"], null) : try(var.fortinet_settings.sku_id["byol"], null)
    version                           = lookup(var.fortinet_settings, "version", null)
  }

  plan {
    name                             = lookup(var.fortinet_settings, "license_type", "payg") == "payg" ? try(var.fortinet_settings.sku_id["payg"], null) : try(var.fortinet_settings.sku_id["byol"], null)
    publisher                        = lookup(var.fortinet_settings, "publisher_id", null)
    product                          = lookup(var.fortinet_settings, "offer_id", null)
  }

  storage_os_disk {
    name                            = lower(format("%s_%s_%s", "md", "osdisk", var.fortinet_settings.fortigate_vm_name))
    caching                         = lookup(var.fortinet_settings, "os_caching_disk", "ReadWrite")
    managed_disk_type               = lookup(var.fortinet_settings, "disk_type", "Standard_LRS")
    create_option                   = "FromImage"
  }

  # Log data disks
  storage_data_disk {
    name                          = lower(format("%s_%s_%s", "md", "data", var.fortinet_settings.fortigate_vm_name))
    managed_disk_type             = lookup(var.fortinet_settings, "disk_type", "Standard_LRS")
    create_option                 = "Empty"
    lun                           = 0
    disk_size_gb                  = "30"
  }

  os_profile {
    computer_name                 = var.fortinet_settings.fortigate_vm_name
    admin_username                = var.fortinet_vm_username
    admin_password                = var.fortinet_vm_password
    custom_data                   = templatefile(format("%s/fgt_single_vm.conf", path.module), {
                                      hostname            = var.fortinet_settings.fortigate_vm_name
                                      type                = lookup(var.fortinet_settings, "license_type", "payg")
                                      license_file        = lookup(var.fortinet_settings, "license_file", "license.txt")
                                      format              = lookup(var.fortinet_settings, "format", "token")
                                      admin_port          = lookup(var.fortinet_settings, "admin_port", "8443")
                                      untrust_ip          = var.fortinet_settings.network.untrust_ip
                                      untrust_netmask     = var.fortinet_settings.network.untrust_netmask
                                      untrust_gateway     = var.fortinet_settings.network.untrust_gateway
                                      trust_ip            = var.fortinet_settings.network.trust_ip
                                      trust_netmask       = var.fortinet_settings.network.trust_netmask
                                    })

  }

  os_profile_linux_config {
    disable_password_authentication = lookup(var.fortinet_settings, "disable_password_authentication", false)
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = azurerm_storage_account.this.primary_blob_endpoint
  }

}


# end
#--------------------------------------------*--------------------------------------------