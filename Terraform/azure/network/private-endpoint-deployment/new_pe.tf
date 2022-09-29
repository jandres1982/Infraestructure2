terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "${var.azure_subscription_id}"
}

data "azurerm_resource_group" "network-rg" {
  name = "${var.network-rg}"
}

data "azurerm_resource_group" "pe-rg"{
  name = "${var.pe-rg}"
}

data "azurerm_virtual_network" "vnet" {
  name                = "${var.network}"
  resource_group_name = data.azurerm_resource_group.network-rg.name
}

data "azurerm_subnet" "subnet" {
  name                 = "${var.subnet}"
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.network-rg.name
}

resource "azurerm_private_link_service" "private-link" {
  name                = "${var.private-link}"
  location            = data.azurerm_resource_group.pe-rg.location
  resource_group_name = data.azurerm_resource_group.pe-rg.name
}

resource "azurerm_private_endpoint" "pe" {
  name                = "${var.pe}"
  location            = data.azurerm_resource_group.pe-rg.location
  resource_group_name = data.azurerm_resource_group.pe-rg.name
  subnet_id           = data.azurerm_subnet.subnet.id

    private_service_connection {
    name                           = "${var.private-link}"
    private_connection_resource_id = azurerm_private_link_service.private-link.id
    is_manual_connection           = false
  }
}