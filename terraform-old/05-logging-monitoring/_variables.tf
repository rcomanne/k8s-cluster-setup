variable "argo_username" {
  type = string
}

variable "argo_password" {
  type      = string
  sensitive = true
}

variable "metrics_server_version" {
  type    = string
  default = "3.11.0"
}

variable "csi_driver_nfs_version" {
  type    = string
  default = "4.4.0"
}

variable "prometheus_version" {
  type    = string
  default = "51.0.3"
}

variable "opensearch_version" {
  type    = string
  default = "2.14.1"
}

variable "opensearch_dashboards_version" {
  type    = string
  default = "2.12.0"
}


variable "fluent_bit_version" {
  type    = string
  default = "0.38.0"
}