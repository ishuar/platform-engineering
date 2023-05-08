resource "helm_release" "nginx_controller" {
  name             = "ingress-nginx-controller"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  version          = "4.6.1"
  create_namespace = true
  namespace        = "ingress-nginx-controller"
  atomic           = true

  ## This is required for ingress-controller to work after Behavioral Changes
  ## https://github.com/Azure/AKS/releases/tag/2022-09-11
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-health-probe-request-path"
    value = "/healthz"
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.32"
  create_namespace = true
  namespace        = "argocd"
  atomic           = true


  ## Why using file() with values -> https://github.com/hashicorp/terraform-provider-helm/issues/838
  values = [
    file("${path.module}/helm-values/argo-cd.yaml")
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
