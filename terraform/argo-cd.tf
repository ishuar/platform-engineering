resource "helm_release" "argo" {
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "5.32"
  create_namespace = true
  namespace        = "argo-cd"

  # atomix = true

  # values = [
  #   "${path.module}/argo-cd.yaml"
  # ]

  depends_on = [
    module.management_cluster
  ]
}
