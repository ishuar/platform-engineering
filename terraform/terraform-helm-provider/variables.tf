## Coming from env vars, prefixed with TF_VAR
variable "DOCKER_LOGIN_ID" {
  type        = string
  description = "(optional) environment variable for docker loging username for OCI repository to work"
}
variable "DOCKER_LOGIN_PASSWORD" {
  type        = string
  description = "(optional) environment variable for docker loging password for OCI repository to work"
}
