resource "vault_generic_endpoint" "this" {
  for_each = var.users
  path                 = "auth/userpass/users/${each.key}"
  ignore_absent_fields = true

  data_json = <<EOT
{
  "policies": ["${each.value}"],
  "password": "changeme"
}
EOT
}
