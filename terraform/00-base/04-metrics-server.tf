resource "argocd_repository" "metrics-server" {
  repo = "https://kubernetes-sigs.github.io/metrics-server/"
  name = "metrics-server"
  type = "helm"
}

resource "argocd_application" "metrics-server" {
  metadata {
    name      = "metrics-server"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.monitoring.metadata.0.name
    source {
      repo_url        = argocd_repository.metrics-server.repo
      chart           = "metrics-server"
      target_revision = var.metrics_server_version

      helm {
        values = file("helm-values/metrics-server/values.yaml")
      }
    }

    sync_policy {
      automated {
        allow_empty = false
        prune       = true
        self_heal   = true
      }
    }

    destination {
      server    = local.argocd_cluster_server
      namespace = "kube-system"
    }
  }

  depends_on = [
    argocd_project.monitoring,
    argocd_repository.metrics-server,
  ]
}