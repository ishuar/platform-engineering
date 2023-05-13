resource "azurerm_user_assigned_identity" "external_secrets_operator" {
  location            = data.azurerm_kubernetes_cluster.management_cluster.location
  name                = "uid-external-secrets-operator"
  resource_group_name = data.azurerm_kubernetes_cluster.management_cluster.resource_group_name
}

resource "azurerm_federated_identity_credential" "external_secrets_operator" {
  name                = "federated-external-secrets-operator"
  resource_group_name = data.azurerm_kubernetes_cluster.management_cluster.resource_group_name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = data.azurerm_kubernetes_cluster.management_cluster.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.external_secrets_operator.id
  subject             = "system:serviceaccount:${kubernetes_namespace_v1.external_secrets_operator.metadata.0.name}:${kubernetes_service_account_v1.external_secrets_operator.metadata.0.name}"
}

## Namespace for External Secrets Operator Kubernetes Service Account
## ref for annotations : https://kubernetes.io/docs/reference/access-authn-authz/admission-controllers/#configuration-annotation-format
resource "kubernetes_namespace_v1" "external_secrets_operator" {
  metadata {
    annotations = {
      "scheduler.alpha.kubernetes.io/node-selector" : "crossplane=false"
      "scheduler.alpha.kubernetes.io/node-selector" : "agentpool=system"
    }
    labels = {
      "crossplane" = "false"
    }
    name = var.external_secrets_operator_service_account_namespace
  }
}

# External Secrets Operator Kubernetes Service Account
resource "kubernetes_service_account_v1" "external_secrets_operator" {
  metadata {
    labels = {
      "app.kubernetes.io/name" : "external-secrets-operator"
      "azure.workload.identity/use" : "true"
      "azure.workload.identity/tenant-id" : data.azurerm_client_config.current.tenant_id
    }
    name      = var.external_secrets_operator_service_account_name
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
    annotations = {
      "azure.workload.identity/client-id" : "${azurerm_user_assigned_identity.external_secrets_operator.client_id}"
    }
  }
}

## ref: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/service_account#default_secret_name
resource "kubernetes_secret_v1" "external_secrets_operator" {
  metadata {
    annotations = {
      "kubernetes.io/service-account.name" = kubernetes_service_account_v1.external_secrets_operator.metadata.0.name
    }
    namespace = kubernetes_namespace_v1.external_secrets_operator.metadata.0.name
    name      = "${var.external_secrets_operator_service_account_name}-secret"
  }

  type = "kubernetes.io/service-account-token"
}
