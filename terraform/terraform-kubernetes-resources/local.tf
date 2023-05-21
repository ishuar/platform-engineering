locals {
  service_principals = ["platform-engineering-dns-admin", "platform-engineering-owner-crossplane"]
  tags = {
    github_repo     = "platform-engineering"
    managed_by      = "terraform"
    directory_level = "terraform-kubernetes-resources"
    level           = "cluster_applications"
  }
}
