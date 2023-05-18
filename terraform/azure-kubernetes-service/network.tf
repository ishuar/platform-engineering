resource "azurerm_virtual_network" "management_cluster" {
  name                = "vnet-mgmt-cluster-${local.tags["github_repo"]}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.management_cluster.location
  resource_group_name = azurerm_resource_group.management_cluster.name
  tags                = local.tags
}

resource "azurerm_subnet" "management_cluster" {
  name                 = "snet-mgmt-${local.tags["github_repo"]}"
  resource_group_name  = azurerm_resource_group.management_cluster.name
  virtual_network_name = azurerm_virtual_network.management_cluster.name
  address_prefixes     = ["10.0.1.0/24"]
}

## Use a domain what you own.
resource "azurerm_dns_zone" "worldofcontainers_tk" {
  name                = "worldofcontainers.tk" ## replace this with a domain what you own.
  resource_group_name = azurerm_resource_group.management_cluster.name
  tags                = local.tags
}
