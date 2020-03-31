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
  vm_os_simple = "${var.vm_os_simple}"  
}


# Azure Resource Group
resource "azurerm_resource_group" "ba_trainer_rg" {
    name = "${var.resource_group}"
    location = "${var.location}"

    tags = {
        dept = "Training"
    }
}

# Security group to allow inbound access on port 3389
resource "azurerm_network_security_group" "ba_trainer_nsg" {
    name = "${var.resource_group}-nsg"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.ba_trainer_rg.name}"

    security_rule = "${var.rdp_allow}"
}

# * Create a virtual network and Subnet
resource "azurerm_virtual_network" "ba_trainer_vnet" {
    name = "${var.resource_group}-vnet"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.ba_trainer_rg.name}"
    address_space = "${var.address_space}"

    tags = {
        dept = "Training"
    }
}

resource "azurerm_subnet" "ba_trainer_subnet" {
    name = "default"
    resource_group_name = "${azurerm_resource_group.ba_trainer_rg.name}"
    virtual_network_name = "${azurerm_virtual_network.ba_trainer_vnet.name}"
    address_prefix = "${var.subnet_address_prefix}"
}

# * Create a public IP
resource "azurerm_public_ip" "ba_vm_pip" {
    count = "${var.nb_public_ip}"
    name = "${var.vm_hostname}-${count.index}-ip"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.ba_trainer_rg.name}"
    public_ip_address_allocation = "${var.public_ip_address_allocation}"
    domain_name_label = "baltic-${element(var.vm_hostname, count.index)}"
}

 # * Create a network interface for the VM
resource "azurerm_network_interface" "ba_vm_nic" {
    count = "${var.nb_instances}"
    name = "${var.vm_hostname}-${count.index}-nic"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.ba_trainer_rg.name}"
    network_security_group_id = "${azurerm_network_security_group.ba_trainer_nsg.id}"

    ip_configuration {
        name ="ipconfig1"
        subnet_id = "${azurerm_subnet.ba_trainer_subnet.id}"
        private_ip_address_allocation = "Dynamic"
        private_ip_address_id = "${length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, list("")), count.index) : ""}"
    }
}

# * Build a Windows VM
resource "azurerm_virtual_machine" "ba_Windows_vm" {
    count = "${(((var.vm_os_id != "" && var.is_custom_image == "true") || contains(list("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")) && var.data_disk == "false") ? var.nb_instances : 0}"
    name = "${var.vm_hostname}${count.index}"
    location = "${var.location}"
    resource_group_name = "${azurerm_resource_group.ba_trainer_rg.name}"
    vm_size = "${var.vm_size}"
    network_interface_ids = ["${element(azurerm_network_interface.ba_vm_nic.*.id, count.index)}"]

    os_disk {

    }

    source_image_reference {
        id        = "${var.vm_os_id}"
        publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
        offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
        sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
        version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
    }

    os_profile{
        computer_name = "${var.vm_hostname}${count.index}"
        admin_username = "${var.admin_username}"
        admin_passwsord = "${var.admin_password}"
    }

    os_profile_windows_config {}

    boot_diagnostics {
        enabled = "${var.boot_diagnostics}"
        storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : ""}"
    }

    tags = {
        dept = "Training"
    }
}