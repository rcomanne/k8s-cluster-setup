resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

resource "argocd_repository" "hashicorp" {
  repo = "https://helm.releases.hashicorp.com"
  name = "hashicorp"
  type = "helm"
}

resource "argocd_project" "hashicorp" {
  metadata {
    name      = "hashicorp"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.vault.metadata.0.name
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    source_namespaces = ["*"]
    source_repos      = [
      argocd_repository.hashicorp.repo
    ]
  }
}

resource "argocd_application" "hc_vault" {
  metadata {
    name      = "vault"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.hashicorp.metadata.0.name
    source {
      repo_url        = argocd_repository.hashicorp.repo
      chart           = "vault"
      target_revision = var.hc_vault_version

      helm {
        values = templatefile("helm-values/vault/values.yaml", {
          vault_host = local.vault_host
        })
      }
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
    }

    destination {
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.vault.metadata.0.name
    }
  }

  depends_on = [
    argocd_project.hashicorp,
    argocd_repository.hashicorp,
    argocd_application.csi-driver-nfs,
  ]
}