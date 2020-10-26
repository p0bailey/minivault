resource "vault_mount" "this" {
  path        = "secrets"
  type        = "kv-v2"
  description = "Secrets"
}

resource "random_password" "api_key" {
  for_each = toset(flatten(keys(var.services)))
  length  = 24
  special = true
  min_numeric = 1
  min_special = 1
}

resource "vault_generic_secret" "this" {
  for_each = toset(flatten(keys(var.services)))
  path = "secrets/services/${each.key}/prod/api_key"

  data_json = jsonencode({
    key = random_password.api_key[each.key].result
})



depends_on = [vault_mount.this]
}
