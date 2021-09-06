data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_network_security_group" "nsg" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.main.name
  location            = data.azurerm_resource_group.main.location
  tags = merge({
    Terraform = true
    },
    var.tags
  )
}

resource "azurerm_network_security_rule" "ns_rules" {
  count             = length(var.ns_rules)
  name              = lookup(var.ns_rules[count.index], "name", "default_rule")
  priority          = var.ns_rules[count.index]["priority"]
  direction         = lookup(var.ns_rules[count.index], "direction", "Any")
  access            = lookup(var.ns_rules[count.index], "access", "Allow")
  protocol          = lookup(var.ns_rules[count.index], "protocol", "*")
  source_port_range = lookup(var.ns_rules[count.index], "source_port_range", "*")
  #destination_port_range      = lookup(var.ns_rules[count.index], "destination_port_range", "*")
  #destination_port_ranges     = lookup(var.ns_rules[count.index], "destination_port_ranges",null)
  destination_port_ranges     = "${split(",", replace("${lookup(var.ns_rules[count.index], "destination_port_range", "*")}", "*", "0-65535"))}"
  source_address_prefix       = lookup(var.ns_rules[count.index], "source_address_prefix", "*")
  destination_address_prefix  = lookup(var.ns_rules[count.index], "destination_address_prefix", "*")
  description                 = lookup(var.ns_rules[count.index], "description", "Security rule for ${lookup(var.ns_rules[count.index], "name", "default_rule")}")
  resource_group_name         = data.azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}