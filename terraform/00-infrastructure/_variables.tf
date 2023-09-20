variable "iso_file" {
  type    = string
  default = "ubuntu-22.04.3-amd64.iso"
}

variable "clone_vm" {
  type    = string
  default = "ubuntu-template"
}

variable "master_cpu_cores" {
  type    = number
  default = 4
}

variable "master_memory" {
  type    = number
  default = 6144
}

variable "worker_cpu_cores" {
  type    = number
  default = 4
}

variable "worker_memory" {
  type    = number
  default = 8192
}

variable "worker_count" {
  type    = number
  default = 3
}

variable "storage_name" {
  type    = string
  default = "bx100"
}

variable "master_storage_size" {
  type    = string
  default = "32G"
}

variable "worker_storage_size" {
  type    = string
  default = "64G"
}