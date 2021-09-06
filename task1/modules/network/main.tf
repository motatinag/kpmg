#
# Virtual Network
#

data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

#TODO: read ddos plan from variables and set if needed
#data "azurerm_network_ddos_protection_plan" "ddos" {
  #name                = var.ddos_plan_name
  #resource_group_name = data.azurerm_resource_group.main.name
#}

resource "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  location            = data.azurerm_resource_group.main.location
  address_space       = var.address_space
  resource_group_name = data.azurerm_resource_group.main.name
  dns_servers         = var.dns_servers

  #  ddos_protection_plan {
  #      id     = data.azurerm_network_ddos_protection_plan.ddos.id
  #      enable = true
  #    }


  tags = merge({
    Terraform = true
    },
    var.tags
  )
}

resource "azurerm_subnet" "subnet" {
  name                 = var.subnet_names[count.index]
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.resource_group_name
  address_prefix       = var.subnet_prefixes[count.index]
  count                = length(var.subnet_names)
  service_endpoints    = var.subnet_service_endpoints[count.index]
}