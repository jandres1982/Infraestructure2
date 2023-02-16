terraform {
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.2.0"
    }
  }
}

provider "vsphere" {
  vsphere_server = "${var.vsphere_vcenter}"
  user           = "${var.vsphere_user}"
  password       = "${var.vsphere_password}"

  allow_unverified_ssl = "${var.vsphere_unverified_ssl}"
}



data "vsphere_datacenter" "datacenter" {
  name = "Prod-SCH-01"
}

data "vsphere_virtual_machine" "vm" {
	name = "${var.vm_name}"
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_datacenter" "datastore" {
  name = "${var.vsphere_datastore}"
  datacenter_id = data.vsphere_datacenter.datacenter.id

}

data "vsphere_vsphere_virtual_disk" "virtual_disk" {

datacenter_id = data.vsphere_datacenter.datacenter.id
virtual_machine_uuid = "${data.vsphere_virtual_machine.vm.id}"
}

resource "vsphere_virtual_disk" "virtual_disk" {
  size               = 40
  type               = "thin"
  vmdk_path          = "/foo/foo.vmdk"
  create_directories = true
  datacenter         = data.vsphere_datacenter.datacenter.name
  datastore          = data.vsphere_datastore.datastore.name
}
