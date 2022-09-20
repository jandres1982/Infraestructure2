variable "vsphere_user" {
  default = "SA-PF01-vCSchiRO@itoper.local"
}

variable "vsphere_password" {
  default = "jsN8pnjFcY8c"
}

variable "vsphere_vcenter" {
  default = "vcenterscs.global.schindler.com"
}

variable "vsphere_unverified_ssl" {
  default = "true"
}

variable "vsphere_datacenter" {
  default = "Prod-SCH-01"
}

variable "vm_name" {
  description = "vSphere vm"
  default     = "zzzwsr0001"
}