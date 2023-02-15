terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
    }
  }
}

provider "azurerm" {
  features {}
  alias = "euprod"
  subscription_id = "505ead1a-5a5f-4363-9b72-83eb2234a43d"
}


provider "azurerm" {
  features {}
  alias = "eunonprod"
  subscription_id = "7fa3c3a2-7d0d-4987-a30c-30623e38756c"
}


data "azurerm_resource_group" "network-rg" {
  provider = azurerm.eunonprod
  name = var.network-rg
}


data "azurerm_virtual_network" "vnet" {
  provider = azurerm.eunonprod
  name                = var.network
  resource_group_name = data.azurerm_resource_group.network-rg.name
}

data "azurerm_subnet" "subnet" {
  provider = azurerm.eunonprod
  name                 = var.subnet
  virtual_network_name = var.network
  resource_group_name  = var.network-rg
}


data "azurerm_resource_group" "pe-rg"{
  provider = azurerm.eunonprod
  name = "${var.rg}"
}

data "azurerm_shared_image" "example" {
  provider = azurerm.euprod
  name                = var.os_2016
  gallery_name        = "ig_gis_win_prod"
  resource_group_name = "rg-gis-prod-imagegallery-01"
}

# create a network interface
resource "azurerm_network_interface" "test" {
  provider = azurerm.eunonprod
  name                = "${var.vm}-01"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = data.azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

data "azurerm_storage_account" "test" {
  provider = azurerm.eunonprod
  name                = var.boot_diagnostics_sa
  resource_group_name = var.boot_diagnostics_rg
}





#create vm

resource "azurerm_windows_virtual_machine" "testingvm" {
  provider = azurerm.eunonprod
  name                  = var.vm
  location              = var.location
  resource_group_name   = var.rg
  network_interface_ids = ["${azurerm_network_interface.test.id}"]
  size                  = var.sku
  admin_username      = "david"
  admin_password      = "Newsetup.1234"
  zone = var.zone

  os_disk {
    name                      = "${var.vm}_osdisk"
    caching                   = "ReadWrite"
    storage_account_type         = "Standard_LRS"
  }

  source_image_id = data.azurerm_shared_image.example.id


  boot_diagnostics {
  storage_account_uri = data.azurerm_storage_account.test.primary_blob_endpoint
  }
}




