variable "external_secrets_operator_service_account_namespace" {
  type        = string
  description = "(optional) Namespace in which service accounts exists for external secrets operator"
  default     = "external-secrets-operator"
}

variable "external_secrets_operator_service_account_name" {
  type        = string
  description = "(optional) Service Account for the external secrets operator to get secrets from Azure Key Vault using workload identity."
  default     = "sa-external-secrets-operator"
}

##? Should come from env vars.
##? Key for env vars are set as default values below, kindly set them with correct values in your shell.
variable "DOCKER_LOGIN_ID" {
  type        = string
  description = "(optional) environment variable for docker loging username for OCI repository to work"
  default     = "TF_VAR_DOCKER_LOGIN_ID"
}
variable "DOCKER_LOGIN_PASSWORD" {
  type        = string
  description = "(optional) environment variable for docker loging password for OCI repository to work"
  default     = "TF_VAR_DOCKER_LOGIN_PASSWORD"
}

variable "GITHUB_CLIENT_ID" {
  type        = string
  description = "(optional) Github client ID of oAuth application to enable SSO with ArgoCD"
  default     = "TF_VAR_GITHUB_CLIENT_ID"
}
variable "GITHUB_CLIENT_SECRET" {
  type        = string
  description = "(optional) Github client Secret of oAuth application to enable SSO with ArgoCD"
  default     = "TF_VAR_GITHUB_CLIENT_ID"
}
