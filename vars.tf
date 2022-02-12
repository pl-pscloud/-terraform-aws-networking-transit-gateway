variable "pscloud_env" {}
variable "pscloud_company" {}
variable "pscloud_project" {}

variable "pscloud_asn" { default = 64512 }
variable "pscloud_auto_accept_shared_attachments" { default = "disable" }
variable "pscloud_default_route_table_association" { default = "disable" }
variable "pscloud_default_route_table_propagation" { default = "disable" }
variable "pscloud_dns_support" { default = "enable" }
variable "pscloud_vpn_ecmp_support" { default = "enable" }

variable "default_route_table_association" { default = "disable" }
variable "pscloud_auto_accept" { default = true }

//
variable "pscloud_vpc_attachments" {
  type = map(object({
    name         = string
    vpc_id       = string
    subnets_ids  = list(string)
  }))
  default = {}
}

variable "pscloud_peer_attachments" {
  type = map(object({
    name              = string
    peer_account_id   = string
    peer_region       = string
    peer_tgw_id       = string

  }))
  default = {}
}

variable "pscloud_route_tables" {
  type = map(object({
    name                = string
  }))
  default = {}
}

variable "pscloud_route_table_associations" {
  type = map(object({
    attachment_type     = string
    attachment_name     = string
    route_table_name    = string
    attachment_id       = string #use only if attachment is from outside

  }))
  default = {}
}

variable "pscloud_route_table_propagations" {
  type = map(object({
    attachment_type     = string
    attachment_name     = string
    route_table_name    = string
    attachment_id       = string #use only if attachment is from outside

  }))
  default = {}
}

variable "pscloud_route_table_routes" {
  type = map(object({
    attachment_type     = string
    cidr                = string
    attachment_name     = string
    route_table_name    = string
    blackhole           = bool
    attachment_id       = string #use only if attachment is from outside
  }))
  default = {}
}

