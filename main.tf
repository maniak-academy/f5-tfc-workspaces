terraform {
  required_providers {
    bigip = {
      source = "F5Networks/bigip"
      version = "1.13.1"
    }
  }
}

provider "bigip" {
  address  = var.bigip_host
  username = var.bigip_user
  password = var.bigip_passwd
}

provider "consul" {
  address    = "192.168.86.70:8500"
  datacenter = "maniak-academy"
}

module bigip-consul-terraform-sync {
  source           = "../"
  services         = var.services
  as3template_path = "${path.module}/templates/"
}

output "as3_json" {
  value = module.bigip-consul-terraform-sync.as3_json
}


