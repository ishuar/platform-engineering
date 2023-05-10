resource "azurerm_resource_group" "management_cluster" {
  name     = "rg-aks-mgmt-${local.tags["github_repo"]}"
  location = "West Europe"
  tags     = local.tags
}

module "management_cluster" {
  source  = "ishuar/aks/azure"
  version = "1.3.1"

  location            = azurerm_resource_group.management_cluster.location
  resource_group_name = azurerm_resource_group.management_cluster.name
  name                = "mgmt-cluster-${local.tags["github_repo"]}"
  dns_prefix          = "managementcluster"
  kubernetes_version  = "1.26.3"

  ## Default node pool
  default_node_pool_name                = "system"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_vm_size             = "standard_d2s_v5"
  default_node_pool_node_count          = 1
  default_node_pool_min_count           = 1
  default_node_pool_max_count           = 2

  ## Networking
  vnet_subnet_id      = azurerm_subnet.management_cluster.id
  network_plugin      = "azure"
  network_plugin_mode = "Overlay"
  service_cidrs       = ["100.1.0.0/16"]
  pod_cidrs           = ["100.2.0.0/16"]
  dns_service_ip      = "100.1.0.100"

  ## Storage profile
  blob_driver_enabled         = true
  disk_driver_enabled         = true
  disk_driver_version         = "v1"
  file_driver_enabled         = true
  snapshot_controller_enabled = false

  # Other features
  enable_maintenance_window = false
  tags                      = local.tags

}
