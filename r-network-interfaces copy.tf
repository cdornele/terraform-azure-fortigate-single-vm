#--------------------------------------------*--------------------------------------------
#  Module: Fortigate - Single VM - Network Interfaces
#--------------------------------------------*--------------------------------------------

resource "azurerm_network_interface" "fgt_untrust_port1" {
  depends_on            = [ 
                          azurerm_public_ip.fgt_public_ip
                          ]
  name                  = lower(format("%s_%s_%s_%s", "nic", lookup(var.fortinet_settings, "fortigate_vm_name", null) , "p1", "untrust"))
  location              = var.location
  resource_group_name   = var.resource_group_name

  ip_configuration {
    name                          = "ipconfig_p1_untrust"
    subnet_id                     = var.fortinet_untrust_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = lookup(var.fortinet_settings.network, "untrust_ip", null)
    public_ip_address_id          = azurerm_public_ip.fgt_public_ip["untrust"].id
  }
    tags = var.tags
}

resource "azurerm_network_interface" "fgt_trust_port2" {
  name                  = lower(format("%s_%s_%s_%s", "nic", lookup(var.fortinet_settings, "fortigate_vm_name", null), "p2", "trust"))
  location              = var.location
  resource_group_name   = var.resource_group_name
  ip_forwarding_enabled = true

  ip_configuration {
    name                          = "ipconfig_p2_trust"
    subnet_id                     = var.fortinet_trust_subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = lookup(var.fortinet_settings.network, "trust_ip", null)
  }
    tags = var.tags
}


# end
#--------------------------------------------*--------------------------------------------