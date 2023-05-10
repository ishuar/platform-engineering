##? KV is public atm, can plan only from the AKS network.
resource "azurerm_key_vault" "management_cluster" {
  name                       = "kv-platform-secrets-01"
  location                   = azurerm_resource_group.management_cluster.location
  resource_group_name        = azurerm_resource_group.management_cluster.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  enable_rbac_authorization  = true
}

resource "azurerm_role_assignment" "key_vault_admin_current_user" {
  scope                = azurerm_key_vault.management_cluster.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = data.azurerm_client_config.current.object_id
}
