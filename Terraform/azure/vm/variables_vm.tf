variable "network-rg" {
  description = "Resource Group"
  default     = "rg-cis-nonprod-network-01"
}

variable "network" {
  description = "VNET Name"
  default     = "EU-NONPROD-VNET"
}

#variable "subnet" {
#  description = "Subnet Name"
#  default     = "sub-frontend-iaas-01"
#}

variable "subnet" {
 type = string
 description = "subnet "
}

variable "location" {
  description = "location"
  default     = "northeurope"
}

#variable "rg" {
#  description = "Resource Group"
#  default     = "rg-cis-test-server-01"
#}

variable "rg" {
 type = string
 description = "rg"
}


variable "os_2016" {
  description = "windows 2016"
  default     = "img-prod-2016datacenter-19052021-01"
}

variable "os_2019" {
  description = "windows 2019"
  default     = "img-prod-2019datacenter-19052021-01"
}


#variable "vm" {
#  description = "VM Name"
#  default     = "zzzwsr0203"
#}


variable "vm" {
 type = string
 description = "vm"
}

#variable "sku" {
#  description = "VM SKU"
#  default     = "Standard_DS1_v2"
#}

variable "sku" {
 type = string
 description = "sku"
}

#variable "zone" {
#  description = "Availability Zone"
#  default     = "2"
#}

variable "zone" {
 type = string
 description = "zone"
}


variable "boot_diagnostics_sa" {
  description = "Boot Diagnostic SA"
  default     = "stnonproddiagnostic0001"
}

variable "boot_diagnostics_rg" {
  description = "Boot Diagnostic RG"
  default     = "rg-cis-nonprod-storage-01"
}

