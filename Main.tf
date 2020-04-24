resource "azurerm_resource_group" "terraformgrp" {
  name     = "tfrg1"
  location = "South Central US"

}
resource "azurerm_proximity_placement_group" "example" {
  name                = "exampleProximityPlacementGroup"
  location            = azurerm_resource_group.terraformgrp.location
  resource_group_name = azurerm_resource_group.terraformgrp.name

  tags = {
    environment = "terraform"
  }
}

resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.terraformgrp.location
  resource_group_name = azurerm_resource_group.terraformgrp.name
}

resource "azurerm_subnet" "example" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.terraformgrp.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefix       = "10.0.2.0/24"
}

resource "azurerm_network_interface" "example" {
  name                = "example-nic"
  location            = azurerm_resource_group.terraformgrp.location
  resource_group_name = azurerm_resource_group.terraformgrp.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.terraformgrp.name
  location            = azurerm_resource_group.terraformgrp.location
  size                = "Standard_E2_v3"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}