path "secrets/data/services/${path}/*" {
  "capabilities" = ["read", "list"]
}

path "secrets/metadata/*" {
  capabilities = ["list"]
}

path "secrets/*" {
  "capabilities" = ["list"]
}
