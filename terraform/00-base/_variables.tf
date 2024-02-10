variable "iso_file" {
  type = string
}

variable "masters" {
  type = map(object({
    mac_address  = string
    ip_address   = string
    cpu_cores    = optional(number, 4)
    memory       = optional(number, 6144)
    storage_size = optional(string, "32G")
    storage_name = optional(string, "bx100")
  }))
}

variable "workers" {
  type = map(object({
    mac_address  = string
    ip_address   = string
    cpu_cores    = optional(number, 4)
    memory       = optional(number, 8192)
    storage_size = optional(string, "64G")
    storage_name = optional(string, "bx100")
  }))
}

variable "argo_cd_version" {
  type    = string
  default = "5.51.6"
}

variable "argo_cd_apps_version" {
  type    = string
  default = "0.13.12"
}

variable "traefik_version" {
  type    = string
  default = "25.0.0"
}

variable "metallb_version" {
  type    = string
  default = "0.13.11"
}

variable "metallb_namespace" {
  type    = string
  default = "metallb-system"
}

variable "csi_driver_nfs_version" {
  type    = string
  default = "4.5.0"
}

variable "metrics_server_version" {
  type    = string
  default = "3.11.0"
}

variable "domain_name" {
  type = string
}

variable "hc_vault_version" {
  type    = string
  default = "0.27.0"
}

variable "cnpg_version" {
  type    = string
  default = "0.19.1"
}

variable "pgadmin_version" {
  type    = string
  default = "1.19.0"
}

variable "grafana_version" {
  type    = string
  default = "7.0.17"
}

variable "kube_prometheus_stack_version" {
  type    = string
  default = "55.6.0"
}

variable "nextcloud_version" {
  type    = string
  default = "4.5.10"
}