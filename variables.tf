variable "services" {
  description = "Consul services monitored by consul-terraform-sync"
  type = map(
    object({
      id        = string
      name      = string
      address   = string
      port      = number
      status    = string
      meta      = map(string)
      tags      = list(string)
      namespace = string

      node                  = string
      node_id               = string
      node_address          = string
      node_datacenter       = string
      node_tagged_addresses = map(string)
      node_meta             = map(string)
    })
  )
}

variable "tenant_name" {
  description = "The name of the tenant"
  type        = string
  default     = "frontend-terraform-sync"
}

variable "pool_name" {
  description = "The name of the web pool where consul-terraform-sync services will reside"
  type        = string
  default     = "frontend_pool"
}

variable "tag_name" {
  description = "The name of the tag to create and use for dynamic address group filtering of Consul service IPs"
  type        = string
  default     = "frontend-terraform-sync"
}

variable "as3template_path" {
  description = "path of as3 template"
  //type        = string
  default     = ""
}

variable "consul_service_tags" {
  description = "Adminstrative tags to add to Consul service address objects. These are existing tags on BIG-IP."
  type        = list(string)
  default     = []
}


variable login_approle_role_id {
  default     = "ab041c65-c8b0-5e20-da6a-2174f7048380"
}
variable login_approle_secret_id {
  default   = "1279fe77-0706-2dc8-26a3-5e11e72d054b"
}