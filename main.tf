provider "azurerm" {
  version = "~>2.0"
 tenant_id       =  "b2beea48-dd5e-4988-995c-773c13cc7499"
  subscription_id =  "e655b264-2703-4b0b-b594-73e0f9fe680c"
  client_id       = "e6403f33-584d-4807-b0e4-f6fb4d392a59"
  client_secret   = "yzQItw11r~ahVzjem4NUt_RC540a4Y39X8"
  features {}
}


resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_virtual_network" "network" {
  name                = "${var.prefix}-VirtualNetwork"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
  tags                = var.tags
}

resource "azurerm_subnet" "subnet_id"{
  name                = "${var.prefix}-subnet"
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name= azurerm_virtual_network.network.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "NetworkSecurityGroup" {
  name                = "${var.prefix}-securitygroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

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
    name                       = "AllInboundDeny"
    priority                   = 4000
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllOutboundDeny"
    priority                   = 4096
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VNetOutboundAllow"
    priority                   = 4010
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "VNetInboundAllow"
    priority                   = 3956
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPInboundAllow"
    priority                   = 4050
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "TCP"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
  tags                         =  var.tags
}




resource "azurerm_public_ip" "api" {
  name                = "${var.prefix}-publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}



resource "azurerm_network_interface" "network_interface" {
  count               = var.value
  name                = "${var.prefix}NetworkInterface-nic${count.index}"

  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = azurerm_subnet.subnet_id.id
    private_ip_address_allocation = "Dynamic"
    
    # load_balancer_backend_address_pools_ids = [azurerm_lb_backend_address_pool.alb_backend.id]
  }
  tags                         =  var.tags
}


resource "azurerm_network_interface_security_group_association" "example" {
  count = var.value
  network_interface_id     =  azurerm_network_interface.network_interface[count.index].id
  network_security_group_id = azurerm_network_security_group.NetworkSecurityGroup.id
}



resource "azurerm_public_ip" "loadBip" {
  name                = "${var.prefix}-PublicIPForLB"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  tags                = var.tags
}



resource "azurerm_lb" "LoadBalancer" {
  name                = "${var.prefix}-LoadBalancer"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.loadBip.id
  }
  tags                = var.tags
}

resource "azurerm_lb_backend_address_pool" "alb_backend" {
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.LoadBalancer.id
  name                = "BackEndAddressPool"
}



resource "azurerm_lb_nat_rule" "natRule" {
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.LoadBalancer.id
  name                           = "HTTPSAccess"
  protocol                       = "Tcp"
  frontend_port                  = 338
  backend_port                   = 338
  frontend_ip_configuration_name = azurerm_lb.LoadBalancer.frontend_ip_configuration[0].name
}

resource "azurerm_network_interface_backend_address_pool_association" "NetworkInferfacebackend" {
  # depends_on = [
  #   azurerm_network_interface.network_interface
  # ]
  count = var.value
  backend_address_pool_id = azurerm_lb_backend_address_pool.alb_backend.id
  ip_configuration_name   = "Configuration"
  network_interface_id    = element(azurerm_network_interface.network_interface.*.id, count.index)
  
 
}

resource "azurerm_availability_set" "set" {
  name                = "${var.prefix}Availability_set"
  location            =  azurerm_resource_group.rg.location
  resource_group_name =  azurerm_resource_group.rg.name
  managed             =  true
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  tags                =  var.tags
}

data "azurerm_resource_group" "image" {
  name = var.resource_group_name
}

data "azurerm_image" "image" {
  name                = "my-web-image"
  resource_group_name = data.azurerm_resource_group.image.name
}

resource "azurerm_linux_virtual_machine" "virtualmachine" {
  # depends_on = [
  #   azurerm_network_interface.ani
  # ]
  count               = var.value
  name                = "${var.prefix}-Machine${count.index}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  availability_set_id   = azurerm_availability_set.set.id
  # delete_data_disks_on_termination = true
  # delete_os_disk_on_termination    = true
  network_interface_ids = [
    azurerm_network_interface.network_interface[count.index].id
  ]



  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
   
  }

  source_image_id = data.azurerm_image.image.id

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # source_image_reference {
  #   publisher = "Canonical"
  #   offer     = "UbuntuServer"
  #   sku       = "16.04-LTS"
  #   version   = "latest"
  # }
  tags = var.tags
}



resource "azurerm_managed_disk" "data" {
  count                           = var.value
  name                            = "${var.prefix}-md${count.index}"
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  create_option                   = "Empty"
  disk_size_gb                    = 10
  storage_account_type            = "Standard_LRS"
  tags = var.tags
}

resource "azurerm_virtual_machine_data_disk_attachment" "data" {
  count                           = var.value
  virtual_machine_id = azurerm_linux_virtual_machine.virtualmachine[count.index].id
  managed_disk_id    = azurerm_managed_disk.data[count.index].id
  lun                = 0
  caching            = "None"
}

