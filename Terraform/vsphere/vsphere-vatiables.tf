#====================#
# vCenter connection #
#====================#

variable "vsphere_user" {
  default = "admsanchona@global.schindler.com"
}

variable "vsphere_password" {
  default = "J@gg3rs.2023!"
}

variable "vsphere_vcenter" {
  default = "shhxap0308.global.schindler.com"
}

variable "vsphere_unverified_ssl" {
  default = "true"
}

variable "vsphere_datacenter" {
  default = "SCC"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  default     = "Cluster"
}