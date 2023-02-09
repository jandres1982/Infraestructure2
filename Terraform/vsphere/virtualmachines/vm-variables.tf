#====================#
# vCenter connection #
#====================#

variable "vsphere_user" {
  default = "xxxxx@vsphere.local"
}

variable "vsphere_password" {
  default = "Newsetup.1234567890"
}

variable "vsphere_vcenter" {
  default = "vcenter_fqdn"
}

variable "vsphere_unverified_ssl" {
  default = "true"
}

variable "vsphere_datacenter" {
  default = "datacenter"
}

variable "vsphere_cluster" {
  description = "vSphere cluster"
  default     = "Cluster"
}

#=========================#
# vSphere virtual machine #
#=========================#

variable "vm_datastore" {
  default = "datastore"
}

variable "vm_network" {
  default = "VM Network"
}

variable "vm_template" {
  default = "w2k16-v1"
}

variable "vm_linked_clone" {
  description = "Use linked clone to create the vSphere virtual machine from the template (true/false). If you would like to use the linked clone feature, your template need to have one and only one snapshot"
  default = "true"
}

variable "vm_ip" {
  default = "vm_ip"
}

variable "vm_netmask" {
  default = "24"
}

variable "vm_gateway" {
  default = "vm_gateway"
}

variable "vm_dns" {
  default = "vm_dns"
}

variable "vm_domain" {
  default = "domain"
}

variable "vm_cpu" {
  default = "2"
}

variable "vm_ram" {
  default = "2048"
}

variable "vm_name" {
  default = "test-v5"
}

variable "os_domain" {
  default = "domain"
}

variable "os_userdomain" {
  default = "user"
}

variable "os_domainpassword" {
  default = "user_pass"
}