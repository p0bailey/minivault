path "secrets/data/services/*" {
  capabilities = ["create", "read", "update", "delete", "list"]
}

path "secrets/metadata/services/*" {
  capabilities = ["list", "read"]
}

path "secrets/metadata/*" {
  capabilities = ["list"]
}

path "secrets/*" {
  "capabilities" = ["list"]
}
