locals {
  name  = "${var.prefix}-pip"
}

resource "azurerm_public_ip" "public_ip" {
  name                   = local.name
  resource_group_name    = var.resource_group_name
  location               = var.location
  allocation_method      = "Static"
  domain_name_label      = var.domain_name_label
  sku                    = var.sku
   tags = merge({
     Terraform = true
   },
   var.tags
   )
}
