#--------------------------------------------*--------------------------------------------
#  Module: Fortigate - Single VM - Variables
#--------------------------------------------*--------------------------------------------

variable "resource_group_name" {
  description = "The name of the resource group in which to create the resources."
  type        = string
}

variable "location" {
  description = "The location/region where the resources will be created."
  type        = string
}

variable "tags" {
  description = "A mapping of tags to assign to the resources."
  type        = map(string)
  default     = {}
}

variable "fortinet_prefix" {
  description = "A prefix for the Fortinet resources."
  type        = string
  default     = "FGT"

}

variable "fortinet_untrust_subnet_id" {
  description = "The ID of the subnet to which the untrust network interface will be attached."
  type        = string
}

variable "fortinet_trust_subnet_id" {
  description = "The ID of the subnet to which the trust network interface will be attached."
  type        = string
}

variable "fortinet_settings" {
  description = "The settings for the Fortinet VM."
}

variable "fortinet_vm_username" {
  description = "The username for the Fortinet VM."
  type        = string
}

variable "fortinet_vm_password" {
  description = "The password for the Fortinet VM."
  type        = string
}

# end
#--------------------------------------------*--------------------------------------------