## Static Public IP for the AKS Ingress controller
resource "azurerm_public_ip" "aks_ingress_controller_lb" {
  name                = "pip-mgmt-cluster-ingress-controller-lb"
  resource_group_name = data.azurerm_kubernetes_cluster.management_cluster.resource_group_name
  location            = data.azurerm_kubernetes_cluster.management_cluster.location
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

##? Namespaces Created via terraform explicitly to apply PodNodeSelector using
##? Available in AKS already , ref: https://learn.microsoft.com/en-us/azure/aks/faq#what-kubernetes-admission-controllers-does-aks-support-can-admission-controllers-be-added-or-removed
##? ref for annotations : https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#configuration-annotation-format
resource "kubernetes_namespace_v1" "nginx_controller" {
  metadata {
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" : "crossplane=false"
    }
    labels = {
      "crossplane" = "false"
    }
    name = "ingress-nginx-controller"
  }
}

resource "helm_release" "nginx_controller" {
  name             = "ingress-nginx-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.6.1"
  create_namespace = false
  namespace        = kubernetes_namespace_v1.nginx_controller.metadata.0.name
  atomic           = false

  ## Why using file() with values -> https://github.com/hashicorp/terraform-provider-helm/issues/838
  values = [
    templatefile("${path.module}/helm-values/ingress-nginx.yaml",
      {
        CUSTOM_AZURE_STATIC_PUBLIC_IP_NAME = azurerm_public_ip.aks_ingress_controller_lb.name
        CUSTOM_STATIC_PUBLIC_IP            = azurerm_public_ip.aks_ingress_controller_lb.ip_address
        CUSTOM_STATIC_PUBLIC_IP_RG_NAME    = azurerm_public_ip.aks_ingress_controller_lb.resource_group_name
      }
    )
  ]
  ## This is required for ingress-controller to work after Behavioral Changes (terraform native syntax)
  ## https://github.com/Azure/AKS/releases/tag/2022-09-11
  ## Coming from values file.
  # set {
  #   name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
  #   value = "/healthz"
  # }
}
