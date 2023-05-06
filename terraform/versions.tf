terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.55"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "helm" {
  kubernetes {
    host                   = module.management_cluster.azurerm_kubernetes_cluster.kube_config.0.host
    cluster_ca_certificate = base64decode(module.management_cluster.azurerm_kubernetes_cluster.kube_config.0.cluster_ca_certificate)
    client_certificate     = base64decode(module.management_cluster.azurerm_kubernetes_cluster.kube_config.0.client_certificate)
    client_key             = base64decode(module.management_cluster.azurerm_kubernetes_cluster.kube_config.0.client_key)
  }
}
