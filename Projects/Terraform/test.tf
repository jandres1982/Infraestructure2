provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server

  # If you have a self-signed cert
  allow_unverified_ssl = true
}

resource "vsphere_virtual_machine_snapshot" "zzzwsr0012" {
  virtual_machine_uuid = "${var.vm_name}.uuid"
  snapshot_name        = "Snapshot Name"
  description          = "This is Demo Snapshot"
  memory               = "true"
  quiesce              = "true"
  remove_children      = "false"
  consolidate          = "true"
}

