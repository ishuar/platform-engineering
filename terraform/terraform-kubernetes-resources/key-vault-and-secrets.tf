data "azurerm_client_config" "current" {}
data "azurerm_subscription" "current" {}

##? KV is public atm, can plan only from the AKS network.
resource "azurerm_key_vault" "management_cluster" {
  name                       = "kv-platform-secrets-01"
  location                   = data.azurerm_kubernetes_cluster.management_cluster.location
  resource_group_name        = data.azurerm_kubernetes_cluster.management_cluster.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id
    secret_permissions = [
      "Get", "Set", "Delete", "List"
    ]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_user_assigned_identity.external_secrets_operator.principal_id
    secret_permissions = [
      "Get",
    ]
  }
}

# #######
# ## SECRETS TO KV
# #######

# ##? Update KV with the app registration secretIds
# ##? depends on current objectID azure RBAC on kV
resource "azurerm_key_vault_secret" "client_secret" {
  for_each = toset(local.service_principals)

  name         = join("-", ["spn", (each.value), "clientsecret"])
  content_type = "password"
  key_vault_id = azurerm_key_vault.management_cluster.id
  value        = azuread_service_principal_password.this[each.value].value
}

resource "azurerm_key_vault_secret" "client_id" {
  for_each = toset(local.service_principals)

  name         = join("-", ["spn", (each.value), "clientid"])
  content_type = "username"
  key_vault_id = azurerm_key_vault.management_cluster.id
  value        = azuread_service_principal.this[each.value].application_id
}
