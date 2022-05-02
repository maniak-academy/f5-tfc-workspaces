log_level = "INFO"
port = 8558
syslog {}
license_path = "/opt/consul/license.hclic"

buffer_period {
  enabled = true
  min     = "5s"
  max     = "20s"
}

vault {
    address = "${VAULT_ADDR}"
    token = "${VAULT_TOKEN}"
}

consul {
    address = "192.168.86.70:8500"
    token = "{{ with secret \"secret/consul\" }}{{ .Data.data.token }}{{ end }}"
}

driver "terraform-cloud" {
  hostname = "https://app.terraform.io"
  organization = "sebbycorp"
  token        = "${TFC_TOKEN}"
      required_providers {
        bigip = {
            source = "F5Networks/bigip"
        }
    }
}
terraform_provider "bigip" {
  address  = "{{ with secret \"secret/f5\" }}{{ .Data.data.mgmtip }}{{ end }}"
  username = "{{ with secret \"secret/f5\" }}{{ .Data.data.username }}{{ end }}"
  password = "{{ with secret \"secret/f5\" }}{{ .Data.data.password }}{{ end }}"
}

task {
  name = "f5-frontend-workspace"
  description = "Front end Application Services"
  module = "github.com/maniak-academy/f5-tfc-workspaces"
  providers = ["bigip"]
  condition "services" {
    names = ["web", "tcp","nginx"]
    datacenter = "maniak-academy"
    namespace  = "default"
  }
}