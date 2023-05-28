#Create Load Balancer
resource "azurerm_lb" "wp3arch-lb" {
  name                = "wp3arch-lb"
  location            = azurerm_resource_group.wp3arch-rg.location
  resource_group_name = azurerm_resource_group.wp3arch-rg.name
  sku				  = "Standard"
  frontend_ip_configuration {
    name                          = "wp3archlbfrontendip"
    public_ip_address_id 		  = azurerm_public_ip.wp3arch.id
  }
  
   
}


#Create Loadbalancing Rules
resource "azurerm_lb_rule" "wp3arch-inbound-rules" {
  loadbalancer_id                = azurerm_lb.wp3arch-lb.id
  resource_group_name            = azurerm_resource_group.wp3arch-rg.name
  name                           = "http-inbound-rule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "wp3archlbfrontendip"
  probe_id                       = azurerm_lb_probe.http-inbound-probe.id
  backend_address_pool_ids        = ["${azurerm_lb_backend_address_pool.wp3arch-backend-pool.id}"]
  disable_outbound_snat			 = "true"
 

}


#Create Probe
resource "azurerm_lb_probe" "http-inbound-probe" {
  resource_group_name = azurerm_resource_group.wp3arch-rg.name
  loadbalancer_id     = azurerm_lb.wp3arch-lb.id
  name                = "http-inbound-probe"
  port                = 80
}


#Create Backend Address Pool
resource "azurerm_lb_backend_address_pool" "wp3arch-backend-pool" {
  loadbalancer_id = azurerm_lb.wp3arch-lb.id
  name            = "wp3arch-backend-pool"
}

resource "azurerm_lb_outbound_rule" "wp3arch-outbound" {
  name                    = "OutboundRule"
  resource_group_name = azurerm_resource_group.wp3arch-rg.name
  loadbalancer_id         = azurerm_lb.wp3arch-lb.id
  protocol                = "Tcp"
  backend_address_pool_id = azurerm_lb_backend_address_pool.wp3arch-backend-pool.id

  frontend_ip_configuration {
    name = "wp3archlbfrontendip"
  }
  
}

#Automated Backend Pool Addition > Gem Configuration to add the network interfaces of the VMs to the backend pool.
resource "azurerm_network_interface_backend_address_pool_association" "wp3arch-pool" {
  count                   = 3
  network_interface_id    = azurerm_network_interface.wp3arch-nic.*.id[count.index]
  ip_configuration_name   = azurerm_network_interface.wp3arch-nic.*.ip_configuration.0.name[count.index]
  backend_address_pool_id = azurerm_lb_backend_address_pool.wp3arch-backend-pool.id

}

