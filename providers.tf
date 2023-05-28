#IaC on Azure Cloud Platform | Declare Azure as the Provider
# Configure the Microsoft Azure Provider
terraform {

  required_version = ">=0.12"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>2.0"
    }
  }

}

provider "azurerm" {
  features {}
  subscription_id = "Subscription ID"
  client_id       = "Client ID"
  client_secret   = "Password of Service Principal"
  tenant_id       = "Tenant ID"
}