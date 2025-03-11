#--------------------------------------------*--------------------------------------------
#  Module: Fortigate - Single VM - Public IP
#--------------------------------------------*--------------------------------------------

resource "azurerm_public_ip" "fgt_public_ip" {
  for_each            = toset(["untrust"])
  name                = format("%s-%s", lookup(var.fortinet_settings, "publicip_name", "pip-fgt"), each.key)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  tags                = var.tags
}

# end
#--------------------------------------------*--------------------------------------------