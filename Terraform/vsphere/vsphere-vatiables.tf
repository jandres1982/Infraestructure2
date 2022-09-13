#====================#
# vCenter connection #
#====================#

variable "vsphere_user" {
  default = "SA-PF01-vCSchiRO@itoper.local"
}

variable "vsphere_password" {
  default = "jsN8pnjFcY8c"
}

variable "vsphere_vcenter" {
  default = "vcenternubes4.global.schindler.com"
}

variable "vsphere_unverified_ssl" {
  default = "true"
}

variable "vsphere_datacenter" {
  default = "Prod-SCH-01"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  default     = "Cluster"
}