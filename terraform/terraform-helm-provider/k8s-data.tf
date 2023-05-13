locals {

  github_repo = "platform-engineering"
  managed_by  = "terraform"
}
data "azurerm_kubernetes_cluster" "management_cluster" {
  name                = "mgmt-cluster-${local.github_repo}"
  resource_group_name = "rg-aks-mgmt-${local.github_repo}"
}

data "azurerm_dns_zone" "worldofcontainers_tk" {
  name                = "worldofcontainers.tk"
  resource_group_name = data.azurerm_kubernetes_cluster.management_cluster.resource_group_name
}
