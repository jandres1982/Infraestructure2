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

data "vsphere_virtual_machine" "snapvm" {
	name = "${var.vm_name}"
	datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine_snapshot" "snapvm" {
  virtual_machine_uuid =  "${data.vsphere_virtual_machine.snapvm.id}"
  snapshot_name        = "Snapshot Name"
  description          = "This is Demo Snapshot"
  memory               = "false"
  quiesce              = "true"
  remove_children      = "false"
  consolidate          = "true"
}