resource "azurerm_resource_group" "management_cluster" {
  name     = "rg-aks-mgmt-${local.tags["github_repo"]}"
  location = "West Europe"
  tags     = local.tags
}

module "management_cluster" {
  source  = "ishuar/aks/azure"
  version = "1.4.0"

  location            = azurerm_resource_group.management_cluster.location
  resource_group_name = azurerm_resource_group.management_cluster.name
  name                = "mgmt-cluster-${local.tags["github_repo"]}"
  dns_prefix          = "managementcluster"
  kubernetes_version  = "1.26.3"

  ##! Azure resource helalth update, The managed cluster control plane has been overloaded and automatically
  ##! restarted. This might impact the availability of your cluster. Update to standard SKU
  sku_tier = "Standard"


  ## Default node pool
  default_node_pool_name                = "system"
  default_node_pool_enable_auto_scaling = true
  default_node_pool_vm_size             = "standard_d2as_v5"
  default_node_pool_min_count           = 1
  default_node_pool_max_count           = 2
  default_node_pool_max_pods            = 110
  default_node_pool_node_labels = {
    node_usage = "base_components"
    crossplane = "false"
  }

  ## Networking
  vnet_subnet_id      = azurerm_subnet.management_cluster.id
  network_plugin      = "azure"
  network_plugin_mode = "Overlay"
  service_cidrs       = ["100.1.0.0/16"]
  pod_cidrs           = ["100.2.0.0/16"]
  dns_service_ip      = "100.1.0.100"

  ## Additional Node Pools
  additional_node_pools = {
    crossplane = {
      name                  = "crossplane"
      vm_size               = "standard_e2ads_v5"
      enable_auto_scaling   = true
      enable_node_public_ip = false
      max_pods              = 110
      min_count             = 1
      max_count             = 2
      node_labels = {
        node_usage = "Crossplane_only"
        crossplane = "true"
      }
    }
  }
  ## Workload Identity
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  ## Other features
  enable_maintenance_window             = false
  enable_cluster_log_monitor_diagnostic = false
  snapshot_controller_enabled           = false
  tags                                  = local.tags
}


##? Allow AKS to read and manage network resources inside in the Resource Group
##? Required for nginx-ingress controller to use a existing PIP for LB.

##! Reference error:
### Error syncing load balancer: failed to ensure load balancer: Retriable: false, RetryAfter: 0s, HTTPStatusCode: 403, RawError: {"error":{"code":" │
### │ AuthorizationFailed","message":"The client '<kubernetes_system_assigned_identity>' with object id '<kubernetes_system_assigned_identity>' does not have authorization t │
### │ o perform action 'Microsoft.Network/publicIPAddresses/read' over scope '/subscriptions/<subscription_id>/resourceGroups/<rg_name_used_for_aks> │
### │ /providers/Microsoft.Network' or the scope is invalid. If access was recently granted, please refresh your credentials."}}

resource "azurerm_role_assignment" "aks_mi_network_contributor" {
  scope                = azurerm_resource_group.management_cluster.id
  role_definition_name = "Network Contributor"
  principal_id         = module.management_cluster.azurerm_kubernetes_cluster.identity[0].principal_id
}

