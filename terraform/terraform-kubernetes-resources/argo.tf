#### Initial Record For ArgoCD ####
resource "azurerm_dns_a_record" "argocd" {
  name                = "argocd"
  zone_name           = data.azurerm_dns_zone.service_learndevops_in.name
  resource_group_name = data.azurerm_dns_zone.service_learndevops_in.resource_group_name
  target_resource_id  = azurerm_public_ip.aks_ingress_controller_lb.id
  ttl                 = 3600
}

##? Namespaces Created via terraform explicitly to apply PodNodeSelector using
##? Available in AKS already , ref: https://learn.microsoft.com/en-us/azure/aks/faq#what-kubernetes-admission-controllers-does-aks-support-can-admission-controllers-be-added-or-removed
##? ref for annotations : https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#configuration-annotation-format
resource "kubernetes_namespace_v1" "argocd" {
  metadata {
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" : "crossplane=false"
    }
    labels = {
      "crossplane" = "false"
    }
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.32"
  create_namespace = false
  namespace        = kubernetes_namespace_v1.argocd.metadata.0.name
  atomic           = true


  ## Why using file() with values -> https://github.com/hashicorp/terraform-provider-helm/issues/838
  values = [
    templatefile("${path.module}/helm-values/argo-cd.yaml",
      {
        DOCKER_LOGIN_ID       = var.DOCKER_LOGIN_ID
        DOCKER_LOGIN_PASSWORD = var.DOCKER_LOGIN_PASSWORD
        GITHUB_CLIENT_ID      = var.GITHUB_CLIENT_ID
        GITHUB_CLIENT_SECRET  = var.GITHUB_CLIENT_SECRET
        ARGOCD_INGRESS_FQDN   = trimsuffix(azurerm_dns_a_record.argocd.fqdn, ".") ## The FQDN of the DNS A Record which has a full-stop at the end is by design.
      }
    )
  ]
}

resource "helm_release" "argocd_bootstrap_app" {
  name             = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  version          = "1.0"
  create_namespace = true
  namespace        = "argocd"
  atomic           = true


  ## Why using file() with values -> https://github.com/hashicorp/terraform-provider-helm/issues/838
  values = [
    file("${path.module}/helm-values/argocd-apps.yaml")
  ]

  depends_on = [
    helm_release.argocd
  ]
}
