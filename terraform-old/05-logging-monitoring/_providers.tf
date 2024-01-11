provider "kubernetes" {}

provider "helm" {
  # Configuration options
}

provider "argocd" {
  server_addr = "argocd.rcomanne.nl:443"
  insecure    = true
  #  port_forward = true
  username = var.argo_username
  password = var.argo_password
}