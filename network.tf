#Create Resource Groups
resource "azurerm_resource_group" "wp3arch-rg" {
  name     = "wp3arch-rg"
  location = "Central India"
}



#Create Virtual Networks > Create Spoke Virtual Network
resource "azurerm_virtual_network" "wp3arch-vnet" {
  name                = "wp3arch-vnet"
  location            = azurerm_resource_group.wp3arch-rg.location
  resource_group_name = azurerm_resource_group.wp3arch-rg.name
  address_space       = ["10.1.0.0/16"]

  tags = {
    environment = "Production Network"
  }
}


#Create Subnet
resource "azurerm_subnet" "wp3arch-subnet" {
  name                 = "wp3arch-subnet"
  resource_group_name  = azurerm_resource_group.wp3arch-rg.name
  virtual_network_name = azurerm_virtual_network.wp3arch-vnet.name
  address_prefixes     = ["10.1.0.0/24"]
}

#Create Private Network Interfaces
resource "azurerm_network_interface" "wp3arch-nic" {
  name                = "corpnic-${count.index + 1}"
  location            = azurerm_resource_group.wp3arch-rg.location
  resource_group_name = azurerm_resource_group.wp3arch-rg.name
  count               = 3

  ip_configuration {
    name                          = "ipconfig-${count.index + 1}"
    subnet_id                     = azurerm_subnet.wp3arch-subnet.id
    private_ip_address_allocation = "Dynamic"

  }
  
}

 resource "azurerm_public_ip" "wp3arch" {
   name                         = "publicIPForLB"
   location                     = azurerm_resource_group.wp3arch-rg.location
   resource_group_name          = azurerm_resource_group.wp3arch-rg.name
   sku							= "Standard"
   allocation_method            = "Static"
 }
