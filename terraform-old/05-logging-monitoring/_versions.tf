terraform {
  required_version = ">= 1.5.0, < 2.0.0"
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.23.0, < 3.0.0"
    }
    argocd = {
      source = "oboukili/argocd"
      version = ">= 6.0.3, < 7.0.0"
    }
  }

  backend "remote" {
    organization = "rcomanne"

    workspaces {
      name = "homelab-logging-monitoring"
    }
  }
}
