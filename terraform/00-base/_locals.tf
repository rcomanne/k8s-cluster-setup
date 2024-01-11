data "azuread_user" "default_admin" {
  object_id = "60a7c9ea-0025-4b92-b276-879186946585"
}

locals {
  argocd_admins = [
    data.azuread_user.default_admin.object_id
  ]
  argo_repository       = "https://argoproj.github.io/argo-helm"
  argocd_cluster_server = "https://kubernetes.default.svc"
  argo_cd_host          = "argocd.${var.domain_name}"
  vault_host            = "vault.${var.domain_name}"
}