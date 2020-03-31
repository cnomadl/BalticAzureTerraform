##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)
##############################################################################

variable "resource_group" {
  description = "This is the name of the Azure resource group to be created"
  default = ""
}

variable "location" {
  description = "The region where the Azure resource is to be created"
  default = "ukwest"
}

# * Security
variable "rdp_allow" {
  description = "This is the network security rule to allow RDP connection to the VM"
  default = [{
    name = "Allow-RDP"
    priority = "300"
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3389"
    source_address_prefix = "*"
    destination_address_prefix = "*"      
  }]
}

variable "ssh_allow" {
  description = "This is the network security rule to allow RDP connection to the VM"
  default = [{
    name = "Allow-SSH"
    priority = "310"
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "22"
    source_address_prefix = "*"
    destination_address_prefix = "*"      
  }]
}

# * Networking
variable "vnet_address_space" {
  description = ""
  default = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = ""
  default = "10.0.2.0/24"
}

variable "nb_public_ip" {
  description = "Number of piblic IPs to assign correspondin to one IP pre VM. Set to 0 to not assign any public IP addresses"
  default = "1"
}

variable "public_ip_address_allocation" {
  description = "Defines how an IP address is assigned. Options are Static or Dynamic"
  default = "dynamic"
}

# * Virtual Machine
variable "nb_instances" {
  description = "Specify the number of VMs to create"
  default = "1"
}

variable "vm_hostname" {
  description = "This is the name of the VM"
  default = ""
}

variable "vm_size" {
  description = "The size of the VM to deploy"
  default = "Standard_D2s_v3"
}

# * Operating System
variable "vm_os_publisher" {
  description = "The name of the publisher of the image you want to deploy"
  default = ""
}

variable "vm_os_offer" {
    description = "The name of the offer you want to deploy. Ignored when vm_os_id or vm_os_simple are provided"
    default= ""
}

variable "vm_os_sku" {
  description = "The SKU of the image you want to deploy"
  default = ""
}

variable "vm_os_version" {
    description = "The version of the OS you want to deploy"
    default = "latest"
}

variable "vm_os_simple" {
    description = "Specify the OS you with to use to get the lates image e.g. WindowsServer, UbuntuServer, CentOS and Debian. DO NOT use this option if you are providing the publisher, offer and SKU or a custom image"
}

variable "vm_os_id" {
  description = "This is the resource ID of the image you with to depoy if useing a custom image. You MUST set is_custom_image to true"
  default = ""
}

variable "is_custom_image" {
    description = "Set this option to true if you are useing a custom image and use only in conjuction with vm_os_id"
    default = "false"
}

# * Diagnostics
variable "boot_diagnostics" {
    description = "Enable or disable boot diagnostics"
    default = "false"
}

variable "boot_diagnostics_sa_type" {
    description = "Storage account type for boot diagnostics"
    default = "Standard_LRS"
}



