
#######
## SERVICE PRINCIPALS CREATION
#######

## Crossplane does not work with workload identity
## GitHub Issue : https://github.com/crossplane-contrib/provider-azure/issues/329
## External Dns & Cert Manager can be used with workload Ideneity but in my POV this is more simplified.

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

# #######
# ## ROLE ASSIGNMENTS
# #######

##? Allow app registration to control DNS zone for external-DNS
resource "azurerm_role_assignment" "dns_admin" {
  scope                = data.azurerm_dns_zone.worldofcontainers_tk.id
  role_definition_name = "DNS Zone Contributor"
  principal_id         = azuread_service_principal.this["platform-engineering-dns-admin"].id
}

##? Allow app registration to create resources on the subscription level
resource "azurerm_role_assignment" "sub_owner_crossplane" {
  scope                = data.azurerm_subscription.current.id
  role_definition_name = "owner"
  principal_id         = azuread_service_principal.this["platform-engineering-owner-crossplane"].id
}
