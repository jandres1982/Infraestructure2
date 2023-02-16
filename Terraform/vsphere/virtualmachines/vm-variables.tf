#====================#
# vCenter connection #
#====================#

variable "vsphere_user" {
  default = "terraform@vsphere.local"
}

variable "vsphere_password" {
  default = "Newsetup.123"
}

variable "vsphere_vcenter" {
  default = "shhxap0249.global.schindler.com"
}

variable "vsphere_unverified_ssl" {
  default = "true"
}

variable "vsphere_datacenter" {
  default = "WCS"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  default     = "offline"
}

#=========================#
# vSphere virtual machine #
#=========================#

variable "vm_datastore" {
  default = "vol_fs_nfs_schindler_008"
}

variable "vm_network" {
  default = "server-vlan-vl102"
}

variable "vm_template" {
  default = "Template_OS2016_Master_June_2019"
}

variable "vm_linked_clone" {
  description = "Use linked clone to create the vSphere virtual machine from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default = "true"
}

variable "vm_domain" {
  default = "global.schindler.com"
}

variable "vm_cpu" {
  default = "2"
}

variable "vm_ram" {
  default = "2048"
}

variable "vm_name" {
  default = "zzzwsr02001"
}

variable "os_domain" {
  default = "global.schindler.com"
}

variable "os_userdomain" {
  default = "svcshhazurevmware"
}

variable "os_domainpassword" {
  default = "Newsetup123456"
}