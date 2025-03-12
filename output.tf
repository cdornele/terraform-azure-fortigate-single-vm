#--------------------------------------------*--------------------------------------------
#  Module: Fortigate - Single VM  - Output
#--------------------------------------------*--------------------------------------------

output "fortigate_untrust_public_ip" {
  description = "Fortigate untrust public IP"
  value       = azurerm_public_ip.fgt_public_ip["untrust"].ip_address
}

output "fortigate_admin_port" {
  description = "Fortigate admin port"
  value       = lookup(var.fortinet_settings, "admin_port", "8443")

}


# end
#--------------------------------------------*--------------------------------------------