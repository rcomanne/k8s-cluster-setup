terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    azuread = {
      source = "hashicorp/azuread"
      version = ">= 2, < 3"
    }
    proxmox = {
      source = "Telmate/proxmox"
      version = ">= 2.9.14, < 3"
    }
    macaddress = {
      source = "ivoronin/macaddress"
      version = ">= 0.3.2, < 0.4.0"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.4.0-alpha.0"
    }
    helm = {
      source = "hashicorp/helm"
      version = ">= 2, < 3"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2, < 3"
    }
    argocd = {
      source = "oboukili/argocd"
      version = ">= 6, < 7"
    }
    vault = {
      source = "hashicorp/vault"
      version = ">= 3, < 7"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = ">= 1.21, < 2"
    }
  }

  backend "remote" {
    organization = "rcomanne"

    workspaces {
      name = "homelab-talos-base"
    }
  }
}
