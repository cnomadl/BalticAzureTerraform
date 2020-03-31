# Define Terraform provider
#Terraform {
 #   require_version = ">= 0.12"
#}

# Configure the Azure Provider
provider "azurerm" {
  version         = "~> 2.0"
  features {}
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Azure authentication variables
variable "subscription_id" {
  description = "Enter Subscription ID for provisioning resources in Azure"
  type = string
}

variable "client_id" {
  description = "Enter Client ID for Application created in Azure AD"
  type = string
}

variable "client_secret" {
  description = "Enter Client secret for Application in Azure AD"
  type = string
}

variable "tenant_id" {
  description = "Enter Tenant ID / Directory ID of your Azure AD. Run Get-AzureSubscription to know your Tenant ID"
  type = string
}