##############################################################################
# Variables File
# 
# Here is where we store the default values for all the variables used in our
# Terraform code. If you create a variable with no default, the user will be
# prompted to enter it (or define it via config file or command line flags.)
##############################################################################

variable "resource_group" {
  type = string
  description = "This is the name of the Azure resource group to be created"
  default = ""
}

variable "location" {
  type = string
  description = "The region where the Azure resource is to be created"
  default = ""
}

# * Security
variable "remote_port" {
  description = "Remote TCP port to be used for access to VMs created via the NSG applied to the nics"
  default = ""
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

variable "allocation_method" {
  type = string
  description = "Defines how an IP address is assigned. Options are Static or Dynamic"
  default = "Dynamic"
}

variable "enable_accelerated_networking" {
  type = bool
  description = "(Optional) Enable accelerated networking on the network interace"
  default = false
}

# * Virtual Machine
variable "nb_instances" {
  description = "Specify the number of VMs to create"
  default = "1"
}

variable "vm_hostname" {
  type = string
  description = "This is the name of the VM"
  default = ""
}

variable "vm_size" {
  type = string
  description = "The size of the VM to deploy"
  default = "Standard_D2s_v3"
}

# * Operating System
variable "vm_os_publisher" {
  type = string
  description = "The name of the publisher of the image you want to deploy"
  default = ""
}

variable "vm_os_offer" {
  type = string
    description = "The name of the offer you want to deploy. Ignored when vm_os_id or vm_os_simple are provided"
    default= ""
}

variable "vm_os_sku" {
  type = string
  description = "The SKU of the image you want to deploy"
  default = ""
}

variable "vm_os_version" {
  type = string
    description = "The version of the OS you want to deploy"
    default = "latest"
}

variable "vm_os_simple" {
  type = string
    description = "Specify the OS you with to use to get the lates image e.g. WindowsServer, UbuntuServer, CentOS and Debian. DO NOT use this option if you are providing the publisher, offer and SKU or a custom image"
    default = ""
}

variable "vm_os_id" {
  type = string
  description = "This is the resource ID of the image you with to depoy if using a custom image. You MUST set is_custom_image to true"
  default = ""
}

variable "is_windows_image" {
  type = string
    description = "Set this option to true if you are using a custom image and use only in conjuction with vm_os_id"
    default = "false"
}

variable "os_disk_type" {
  type = string
  description = ""
  default = "Standard_LRS"
}
# * Diagnostics
variable "boot_diagnostics" {
  type = bool
    description = "(Optional) Enable or disable boot diagnostics"
    default = "false"
}

variable "boot_diagnostics_sa_type" {
  type = string
    description = "(Optional) Storage account type for boot diagnostics"
    default = "Standard_LRS"
}

# Credentials
variable "admin_username" {
  type = string
  description = "This is the VM admin username"
}
variable "admin_password" {
  type = string
  description = "This is the VM admin password"
}

#Tags
variable "created_by" {
  type = string
  description = ""
}

variable "resource_usage" {
  type = string
  description = ""
}



