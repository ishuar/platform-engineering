locals {
  service_principals = ["platform-engineering-dns-admin", "platform-engineering-key-vault-admin", "platform-engineering-owner-crossplane"]
}

data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

#######
## SERVICE PRINCIPALS CREATION
#######

resource "azuread_application" "this" {
  for_each = toset(local.service_principals)

  display_name = each.value
  owners       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal" "this" {
  for_each = toset(local.service_principals)

  application_id               = azuread_application.this[each.value].application_id
  app_role_assignment_required = false
  owners                       = [data.azurerm_client_config.current.object_id]
}

resource "azuread_service_principal_password" "this" {
  for_each             = toset(local.service_principals)
  service_principal_id = azuread_service_principal.this[each.value].id
}

#######
## SECRETS TO KV
#######

##? Update KV with the app registration secretIds
##? depends on current objectID azure RBAC on kV
resource "azurerm_key_vault_secret" "client_secret" {
  for_each = toset(local.service_principals)

  name         = join("-", ["spn", (each.value), "clientsecret"])
  content_type = "password"
  key_vault_id = azurerm_key_vault.management_cluster.id
  value        = azuread_service_principal_password.this[each.value].value

  depends_on = [
    azurerm_role_assignment.key_vault_admin_current_user
  ]
}

resource "azurerm_key_vault_secret" "client_id" {
  for_each = toset(local.service_principals)

  name         = join("-", ["spn", (each.value), "clientid"])
  content_type = "username"
  key_vault_id = azurerm_key_vault.management_cluster.id
  value        = azuread_service_principal.this[each.value].application_id

  depends_on = [
    azurerm_role_assignment.key_vault_admin_current_user
  ]
}

##? Secrets for External DNS
resource "azurerm_key_vault_secret" "external_dns_client_id" {

  name         = "externaldnsclientid"
  content_type = "username"
  key_vault_id = azurerm_key_vault.management_cluster.id
  value        = azuread_service_principal.this["platform-engineering-dns-admin"].application_id

  depends_on = [
    azurerm_role_assignment.key_vault_admin_current_user
  ]
}
resource "azurerm_key_vault_secret" "external_dns_client_secret" {

  name         = "externaldnsclientsecret"
  content_type = "password"
  key_vault_id = azurerm_key_vault.management_cluster.id
  value        = azuread_service_principal_password.this["platform-engineering-dns-admin"].value

  depends_on = [
    azurerm_role_assignment.key_vault_admin_current_user
  ]
}

#######
## ROLE ASSIGNMENTS
#######

##? Allow app registration to control DNS zone for external-DNS
resource "azurerm_role_assignment" "dns_admin" {
  scope                = azurerm_dns_zone.worldofcontainers_tk.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.this["platform-engineering-dns-admin"].id
}

##? Allow app registration to create resources on the subscription level
resource "azurerm_role_assignment" "sub_owner_crossplane" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "owner"
  principal_id         = azuread_service_principal.this["platform-engineering-owner-crossplane"].id
}

##? Allow app registration to control DNS zone for external-secrets-operator
##? The clientID and clientSecret will be created as a secret manually on the cluster.
##? After this all secrets will be managed via external-secrets-operator using azure KV backend.
resource "azurerm_role_assignment" "kv_secrets_officer" {
  scope                = azurerm_key_vault.management_cluster.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = azuread_service_principal.this["platform-engineering-key-vault-admin"].id
}
