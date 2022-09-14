terraform {
<<<<<<< HEAD
  required_providers {
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.2.0"
=======
    required_providers {
        vsphere = {
            source = "hasicorp/vsphere"
            version = "2.2.0"
        }
>>>>>>> b6938937e7b543499106b995a3451cf9dd3a2453
    }
  }
}

provider "vsphere" {

  user                 = "terraform@vsphere.local"
  password             = "New.setup123"
  vsphere_server       = "shhxap0308.global.schindler.com"
  allow_unverified_ssl = "true"

}


data "vsphere_datacenter" "SCC" {
  name = "SCC"
}


data "vsphere_virtual_machine" "proxyveeam" {
	name = "proxyveeam"
	datacenter_id = data.vsphere_datacenter.SCC.id
}

resource "vsphere_virtual_machine_snapshot" "proxyveeam" {
<<<<<<< HEAD
  virtual_machine_uuid =  "${data.vsphere_virtual_machine.proxyveeam.id}"
  snapshot_name        = "Snapshot Name"
  description          = "This is Demo Snapshot"
  memory               = "false"
  quiesce              = "true"
  remove_children      = "false"
  consolidate          = "true"
=======
    vsphere_virtual_machine_uuid = "${data.vsphere_virtual_machine.proxyveeam.id}"
    snapshot_name = "Snapshot Name"
    description = "This is Demo Snapshot"
    memory = "false"
    quiesce = "true"
    remove_children = "false"
    consolidate = "true"
>>>>>>> b6938937e7b543499106b995a3451cf9dd3a2453
}