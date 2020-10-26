
data "template_file" "this" {
  template = file("policies/policy-services-ro.tpl")
  for_each = var.services

  vars = {
    path  = each.key
  }
}

resource "vault_policy" "this" {
  for_each = var.services
  name   = each.key
  policy = data.template_file.this[each.key].rendered
}

resource "vault_policy" "services-admin" {
  name   = "services-admin"
  policy = file("policies/policy-services-admin.hcl")
}
