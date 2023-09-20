variable "argo_cd_version" {
  type    = string
  default = "5.46.5"
}

variable "traefik_version" {
  type    = string
  default = "24.0.0"
}

variable "metallb_version" {
  type    = string
  default = "0.13.11"
}

variable "metallb_namespace" {
  type    = string
  default = "metallb-system"
}