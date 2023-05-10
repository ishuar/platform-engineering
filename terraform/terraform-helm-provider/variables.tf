## Coming from env vars, prefixed with TF_VAR
variable "DOCKER_LOGIN_ID" {
  type        = string
  description = "(optional) environment variable for docker loging username for OCI repository to work"
}
variable "DOCKER_LOGIN_PASSWORD" {
  type        = string
  description = "(optional) environment variable for docker loging password for OCI repository to work"
}

variable "GITHUB_CLIENT_ID" {
  type        = string
  description = "(optional) Github client ID of oAuth application to enable SSO with ArgoCD"
}
variable "GITHUB_CLIENT_SECRET" {
  type        = string
  description = "(optional) Github client Secret of oAuth application to enable SSO with ArgoCD"
}
