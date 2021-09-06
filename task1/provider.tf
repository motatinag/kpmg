
terraform {
  required_version = ">= 0.12.8, < 0.13"
}

provider "azurerm" {
 
  version = "=2.27.0"

  features {}
}

provider "random" {
  version = "=2.3.0"

}