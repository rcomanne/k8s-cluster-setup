terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.14, < 3.0.0"
    }
    macaddress = {
      source = "ivoronin/macaddress"
      version = ">= 0.3.2, < 0.4.0"
    }
  }
}
