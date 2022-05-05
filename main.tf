terraform {
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
      version = "1.13.1"
    }
    vault = {
      source = "hashicorp/vault"
      version = "3.5.0"
    }
  }
}


provider "vault" {
  address = "http://192.168.86.69:8200"
  auth_login {
    path = "auth/approle/login"

    parameters = {
      role_id   = var.login_approle_role_id
      secret_id = var.login_approle_secret_id
    }
  }
}

resource "vault_pki_secret_backend_cert" "app" {

  backend = "pki_int/issue/"
  name = "example-dot-com"

  common_name = "test.example.com"
}

data "template_file" "as3_init_service" {
  for_each = local.grouped
  template = fileexists("${var.as3template_path}/${distinct(each.value.*.meta.AS3TMPL)[0]}.tmpl") ? file("${var.as3template_path}/${distinct(each.value.*.meta.AS3TMPL)[0]}.tmpl") : file("${path.module}/as3templates/${distinct(each.value.*.meta.AS3TMPL)[0]}.tmpl") 

  vars = {
    app_name          = each.key
    vs_server_address = jsonencode(distinct(each.value.*.meta.VSIP))
    domain            = format("%s-domain", each.key)
    vs_server_port    = tonumber(distinct(each.value.*.meta.VSPORT)[0])
    pool_name         = format("%s-pool", each.key)
    service_address   = jsonencode(distinct(each.value.*.node_address))
    service_port      = jsonencode(element(distinct(each.value.*.port), 0))
    client_ssl        = format("%s-clientssl", each.key)
    cookie_profile    = format("%s-cookie", each.key)
  }
}

data "template_file" "as3_init_fs" {
  template = file("${path.module}/as3_config.tmpl")
  vars = {
    tenant_name = var.tenant_name,
    app_service = join("", values(data.template_file.as3_init_service).*.rendered)
  }
}

resource "bigip_as3" "as3-consul" {
  as3_json = jsonencode(jsondecode(data.template_file.as3_init_fs.rendered))
}

locals {
  addresses = [
    for id, s in var.services :
    s.node_address
  ]

  # Create a map of service names to instance IDs
  service_ids = transpose({
    for id, s in var.services : id => [s.name]
    if lookup(s.meta, "VSIP", "") != "" && lookup(s.meta, "VSPORT", "") != ""
  })

  # Group service instances by name
  grouped = { for name, ids in local.service_ids :
    name => [
      for id in ids : var.services[id]
      if lookup(var.services[id].meta, "VSIP", "") != "" && lookup(var.services[id].meta, "VSPORT", "") != ""
    ]
  }

}

output "as3_json" {
  value = data.template_file.as3_init_fs.rendered
}