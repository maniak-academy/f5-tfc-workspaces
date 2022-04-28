variable "services" {
  description = "Consul services monitored by Consul-Terraform-Sync"
  type = map(
    object({
      id        = string
      name      = string
      kind      = string
      address   = string
      port      = number
      meta      = map(string)
      tags      = list(string)
      namespace = string
      status    = string

      node                  = string
      node_id               = string
      node_address          = string
      node_datacenter       = string
      node_tagged_addresses = map(string)
      node_meta             = map(string)

      cts_user_defined_meta = map(string)
    })
  )
}

#
# Your module for can include input variables to be used by CTS operators for
# customizing the module based on their infastructure. CTS supports both
# optional and required variables.
#
variable "address_group_prefix" {
  description = "Prefix added to each address group name"
  type        = string

  # Set the default argument to a default value to declare an optional variable.
  # Omit the default argument for required ariables.
  default = ""

  # Set the sensitive flag for input variables that contain secret or sensitive
  # values. When set, Terraform will redact the value from output when Terraform
  # commands are run.
  sensitive = false
}

variable "address_group_tags" {
  description = "List of tag names to add to each address group for filtering of Consul service IPs"
  type        = list(string)
  default     = []
}

variable bigip_host {
  description = "The F5 BIG-IP hostname or IP address"
  type        = string
  default     = "192.168.86.33"
}
variable bigip_user {
  description = "The F5 BIG-IP username"
  type        = string
  default     = "admin"
}
variable bigip_passwd {
  description = "The F5 BIG-IP password"
  type        = string
  default     = "W3lcome098!"
}

