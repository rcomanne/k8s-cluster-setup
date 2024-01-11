provider "azuread" {}

provider "proxmox" {
  pm_api_url      = "https://pve.home:8006/api2/json"
  pm_tls_insecure = true

  pm_log_enable = true
  pm_debug      = true
}

provider "talos" {}

provider "helm" {
  kubernetes {
    host                   = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
    cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  }
}

provider "kubernetes" {
  host                   = data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.host
  cluster_ca_certificate = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
  client_certificate     = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(data.talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
}

provider "argocd" {
  plain_text                  = true
  port_forward_with_namespace = helm_release.argo_cd.namespace
  username                    = "admin"
  password                    = random_password.argocd_admin.result
}

provider "vault" {
  address = "https://${local.vault_host}"
}

provider "postgresql" {
  host     = data.kubernetes_service.traefik.status[0].load_balancer[0].ingress[0].ip
  port     = 5432
  database = "postgres"
  username = data.kubernetes_secret.postgres_superuser.data.username
  password = data.kubernetes_secret.postgres_superuser.data.password
}