
# Create Network Security Group and rule
resource "azurerm_network_security_group" "wp3arch-nsg" {
  name                = "wp3arch-nsg"
  location            = azurerm_resource_group.wp3arch-rg.location
  resource_group_name = azurerm_resource_group.wp3arch-rg.name


  #Add rule for Inbound Access
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "HTTP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


#Connect NSG to Subnet
resource "azurerm_subnet_network_security_group_association" "wp3arch-nsg-assoc" {
  subnet_id                 = azurerm_subnet.wp3arch-subnet.id
  network_security_group_id = azurerm_network_security_group.wp3arch-nsg.id
}



#Availability Set - Fault Domains [Rack Resilience]
resource "azurerm_availability_set" "vmavset" {
  name                         = "vmavset"
  location                     = azurerm_resource_group.wp3arch-rg.location
  resource_group_name          = azurerm_resource_group.wp3arch-rg.name
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
  tags = {
    environment = "Production"
  }
}

resource "azurerm_managed_disk" "wp3arch" {
   count                = 3
   name                 = "datadisk_existing_${count.index}"
   location             = azurerm_resource_group.wp3arch-rg.location
   resource_group_name  = azurerm_resource_group.wp3arch-rg.name
   storage_account_type = "Standard_LRS"
   create_option        = "Empty"
   disk_size_gb         = "1023"
 }

resource "azurerm_virtual_machine" "wp3arch" {
   count                 = 3
   name                  = "wp3archvm${count.index}"
   location              = azurerm_resource_group.wp3arch-rg.location
   availability_set_id   = azurerm_availability_set.vmavset.id
   resource_group_name   = azurerm_resource_group.wp3arch-rg.name
   network_interface_ids = [element(azurerm_network_interface.wp3arch-nic.*.id, count.index)]
   vm_size               = "Standard_DS1_v2"

   # Uncomment this line to delete the OS disk automatically when deleting the VM
    delete_os_disk_on_termination = true

   # Uncomment this line to delete the data disks automatically when deleting the VM
    delete_data_disks_on_termination = true

   storage_image_reference {
     publisher = "Canonical"
     offer     = "0001-com-ubuntu-server-jammy"
     sku       = "22_04-lts"
     version   = "latest"
   }

   storage_os_disk {
     name              = "myosdisk${count.index}"
     caching           = "ReadWrite"
     create_option     = "FromImage"
     managed_disk_type = "Standard_LRS"
   }

   # Optional data disks
   storage_data_disk {
     name              = "datadisk_new_${count.index}"
     managed_disk_type = "Standard_LRS"
     create_option     = "Empty"
     lun               = 0
     disk_size_gb      = "1023"
   }
   	
   storage_data_disk {
     name            = element(azurerm_managed_disk.wp3arch.*.name, count.index)
     managed_disk_id = element(azurerm_managed_disk.wp3arch.*.id, count.index)
     create_option   = "Attach"
     lun             = 1
     disk_size_gb    = element(azurerm_managed_disk.wp3arch.*.disk_size_gb, count.index)
   }

   os_profile {
     computer_name  = "wp3arch"
     admin_username = "admin"
     admin_password = "Password1234!"
   }

   os_profile_linux_config {
     disable_password_authentication = false
   }

}