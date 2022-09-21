resource "azurerm_resource_group" "rg" {
  name     = "${var.rg}"
  location = "${var.location}"
}

resource "azurerm_storage_account" "storageaccount" {
  name                     = "${var.storageaccount}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "fileshare" {
  name                 = "${var.sharename}"
  storage_account_name = azurerm_storage_account.storageaccount.name
  quota                = 50
}

resource "azurerm_storage_share_file" "file" {
  name             = "local.txt"
  storage_share_id = azurerm_storage_share.fileshare.id
  source           = "welcome.txt"
}