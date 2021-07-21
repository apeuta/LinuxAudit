provider "azurerm" {
  subscription_id = var.subscriptionID

  features {}
}

#Create a Resource Group
resource "azurerm_resource_group" "auditRG" {
  name                = var.resourceGroupName
  location            = var.location
}

#Create Network Security Group
resource "azurerm_network_security_group" "auditSG" {
  name                = var.securityGroup
  location            = "${azurerm_resource_group.auditRG.location}"
  resource_group_name = "${azurerm_resource_group.auditRG.name}"
}

#Create Rule to Allow RDP Inbound
resource "azurerm_network_security_rule" "rdp" {
  name                        = "SSH"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = "${azurerm_resource_group.auditRG.name}"
  network_security_group_name = azurerm_network_security_group.auditSG.name
}

#Create VN within RG
resource "azurerm_virtual_network" "auditVN" {
  name                  = var.virtualNetwork
  address_space         = ["10.0.0.0/16"]
  location              = "${azurerm_resource_group.auditRG.location}"
  resource_group_name   = "${azurerm_resource_group.auditRG.name}"
}

#Create Subnets
resource "azurerm_subnet" "subnet-1" {
  name                  = "advslin-subnet-1"
  resource_group_name   = "${azurerm_resource_group.auditRG.name}"
  virtual_network_name  = azurerm_virtual_network.auditVN.name
  address_prefix        = "10.0.1.0/24"
}

#Associate Subnet with NSG
resource "azurerm_subnet_network_security_group_association" "test" {
  subnet_id                 = "${azurerm_subnet.subnet-1.id}"
  network_security_group_id = "${azurerm_network_security_group.auditSG.id}"
}

#Create Public IP
resource "azurerm_public_ip" "dataip" {
  name                          = "ASLPublicIP"
  location                      = "${azurerm_resource_group.auditRG.location}"
  resource_group_name           = "${azurerm_resource_group.auditRG.name}"
  allocation_method             = "Dynamic"
}

#Create Network Interface
resource "azurerm_network_interface" "vm_interface" {
  name                  = "asl_NIC"
  location              = "${azurerm_resource_group.auditRG.location}"
  resource_group_name   = "${azurerm_resource_group.auditRG.name}"
  ip_configuration {
    name                            = "UbuntuServer"
    subnet_id                       = "${azurerm_subnet.subnet-1.id}"
    private_ip_address_allocation   = "dynamic"
    public_ip_address_id            = "${azurerm_public_ip.dataip.id}"
  }
}

#Create a VM
resource "azurerm_virtual_machine" "windows" {
  name                              = var.vm_name
  location                          = "${azurerm_resource_group.auditRG.location}"
  resource_group_name               = "${azurerm_resource_group.auditRG.name}"
  network_interface_ids             = ["${azurerm_network_interface.vm_interface.id}"]
  vm_size                           = "Standard_DS1_v2"
  delete_os_disk_on_termination     = "true"
  delete_data_disks_on_termination   = "true"

  storage_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }

  storage_os_disk {
    name = var.disk_name
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name = "ASLinux"
    admin_username = var.vm_admin
    admin_password = var.vm_pass
  }

    os_profile_linux_config {
    disable_password_authentication = false
  }
}

#Retrieve Public IP
data "azurerm_public_ip" "test" {
  name = "${azurerm_public_ip.dataip.name}"
  resource_group_name = "${azurerm_resource_group.auditRG.name}"
  depends_on = [azurerm_virtual_machine.windows]
}
output "public_ip_address" {
  value = "${data.azurerm_public_ip.test.ip_address}"
}
