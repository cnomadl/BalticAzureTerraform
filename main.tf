##############################################################################
# * Baltic Virtual Machine Deployment Using Terraform on Azure
# 
# This Terraform configuration will create the following:
#
# Resource group with a virtual network and subnet
# An Ubuntu Linux server running Apache

##############################################################################

# * Modules
module "os" {
  source = "./modules/os"
  vm_os_simple = var.vm_os_simple  
}


# Azure Resource Group
data "azurerm_resource_group" "ba_trainer_rg" {
    name = var.resource_group   
}

resource "random_id" "ba_vm_sa" {
    keepers = {
        vm_hostname = var.vm_hostname
    }

    byte_length = 6
}

# Storage Account
resource "azurerm_storage_account" "ba_vm_sa" {
  count                    = var.boot_diagnostics ? 1 : 0
  name                     = "bootdiag${lower(random_id.ba_vm_sa.hex)}"
  resource_group_name      = data.azurerm_resource_group.ba_trainer_rg.name
  location                 = data.azurerm_resource_group.ba_trainer_rg.location
  account_tier             = element(split("_", var.boot_diagnostics_sa_type), 0)
  account_replication_type = element(split("_", var.boot_diagnostics_sa_type), 1)
  #tags                     = var.tags
}

# Security group to allow inbound access
resource "azurerm_network_security_group" "ba_trainer_nsg" {
    name                = "${var.resource_group}-nsg"
    location            = data.azurerm_resource_group.ba_trainer_rg.location
    resource_group_name = data.azurerm_resource_group.ba_trainer_rg.name
}

resource "azurerm_network_security_rule" "ba_nsg_rule" {
    name                        = "allow_remote_${coalesce(var.remote_port, module.os.calculated_remote_port)}_in_all"
    resource_group_name         = data.azurerm_resource_group.ba_trainer_rg.name
    description                 = "Allow remote protocol in from all locations"
    priority                    = 100
    direction                   = "Inbound"
    access                      = "Allow"
    protocol                    = "Tcp"
    source_port_range           = "*"
    destination_port_range      = coalesce(var.remote_port, module.os.calculated_remote_port)
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
    network_security_group_name = azurerm_network_security_group.ba_trainer_nsg.name
}

# * Create a virtual network and Subnet
resource "azurerm_virtual_network" "ba_trainer_vnet" {
    name                = "${var.resource_group}-vnet"
    location            = data.azurerm_resource_group.ba_trainer_rg.location
    resource_group_name = data.azurerm_resource_group.ba_trainer_rg.name
    address_space       = var.vnet_address_space

    tags = {
        Resource = "Virtual Network"
        dept = "Training"
        createdBy = var.created_by
        ResourceUsage = var.resource_usage
    }
}

resource "azurerm_subnet" "ba_trainer_subnet" {
    name = "default"
    resource_group_name  = data.azurerm_resource_group.ba_trainer_rg.name
    virtual_network_name = azurerm_virtual_network.ba_trainer_vnet.name
    address_prefix       = var.subnet_address_prefix
}

# * Create a public IP
resource "azurerm_public_ip" "ba_vm_pip" {
    count               = var.nb_public_ip
    name                = "${var.vm_hostname}-${count.index}-ip"
    location            = data.azurerm_resource_group.ba_trainer_rg.location
    resource_group_name = data.azurerm_resource_group.ba_trainer_rg.name
    allocation_method   = var.allocation_method
    domain_name_label   = "baltic-${lower(var.vm_hostname)}${count.index}"

                      
}

# * Create a network interface for the VM
resource "azurerm_network_interface" "ba_vm_nic" {
    count                         = var.nb_instances
    name                          = "${var.vm_hostname}-${count.index}-nic"
    location                      = data.azurerm_resource_group.ba_trainer_rg.location
    resource_group_name           = data.azurerm_resource_group.ba_trainer_rg.name
    enable_accelerated_networking = var.enable_accelerated_networking

    ip_configuration {
        name                          ="ipconfig1"
        subnet_id                     = azurerm_subnet.ba_trainer_subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = length(azurerm_public_ip.ba_vm_pip.*.id) > 0 ? element(concat(azurerm_public_ip.ba_vm_pip.*.id, list("")), count.index) : ""
    }
}

resource "azurerm_network_interface_security_group_association" "ba_nsga" {
    count                     = var.nb_instances
    network_interface_id      = azurerm_network_interface.ba_vm_nic[count.index].id
    network_security_group_id = azurerm_network_security_group.ba_trainer_nsg.id
}

# * Build a Windows VM
resource "azurerm_virtual_machine" "ba_windows_vm" {
    count                 = (var.is_windows_image || contains(list(var.vm_os_simple, var.vm_os_offer), "Windows")) ? var.nb_instances : 0
    name                  = "${var.vm_hostname}${count.index}"
    location              = data.azurerm_resource_group.ba_trainer_rg.location
    resource_group_name   = data.azurerm_resource_group.ba_trainer_rg.name
    vm_size               = var.vm_size
    network_interface_ids = [element(azurerm_network_interface.ba_vm_nic.*.id, count.index)]

    storage_os_disk {
        name              = "${var.vm_hostname}${count.index}-osdisk"
        create_option     = "FromImage"
        managed_disk_type = var.os_disk_type
    }

    storage_image_reference {
        id        = var.vm_os_id
        publisher = var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""
        offer     = var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""
        sku       = var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""
        version   = var.vm_os_id == "" ? var.vm_os_version : ""
    }

    os_profile{
        computer_name   = "${var.vm_hostname}${count.index}"
        admin_username  = var.admin_username
        admin_password = var.admin_password
    }

    os_profile_windows_config {
        provision_vm_agent = true
    }

    boot_diagnostics {
        enabled     = var.boot_diagnostics
        storage_uri = var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.ba_vm_sa.*.primary_blob_endpoint) : ""
    }

    tags = {
        Resource = "Virtual Machine"
        dept = "Training"
        createdBy = var.created_by
        ResourceUsage = var.resource_usage
    }
}