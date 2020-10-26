resource "vault_mount" "this" {
  path        = "secrets"
  type        = "kv-v2"
  description = "Secrets"
}



resource "random_password" "api_key" {
  length  = 24
  special = true
  min_numeric = 1
  min_special = 1
}

resource "vault_generic_secret" "this" {
  for_each = var.services
  path = "secrets/services/${each.key}/prod"

  data_json = jsonencode({
    API_KEY = random_password.api_key.result
})

depends_on = [vault_mount.this]
}
