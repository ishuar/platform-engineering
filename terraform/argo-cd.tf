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
    file("${path.module}/argo-cd.yaml")
  ]

  depends_on = [
    module.management_cluster
  ]
}

resource "helm_release" "argocd-bootstrap-app" {
  name             = "argocd-apps"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argocd-apps"
  version          = "1.0"
  create_namespace = true
  namespace        = "argocd"
  atomic           = true


  ## Why using file() with values -> https://github.com/hashicorp/terraform-provider-helm/issues/838
  values = [
    file("${path.module}/argocd-apps.yaml")
  ]

  depends_on = [
    helm_release.argocd
  ]
}
