data "azurerm_resource_group" "main" {
  name = var.resource_group_name
}

resource "azurerm_application_insights" "this" {
  name                = var.name
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  application_type    = "Web"
  tags = merge({
    Terraform = true
    },
    var.tags
  )
}