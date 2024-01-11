resource "argocd_repository" "metrics-server" {
  repo = "https://kubernetes-sigs.github.io/metrics-server/"
  name = "metrics-server"
  type = "helm"
}

resource "argocd_application" "metrics-server" {
  metadata {
    name      = "metrics-server"
    namespace = data.kubernetes_namespace.argo.metadata.0.name
  }

  spec {
    project = argocd_project.monitoring.metadata.0.name
    source {
      repo_url        = argocd_repository.metrics-server.repo
      chart           = "metrics-server"
      target_revision = var.metrics_server_version

      helm {
        values = file("helm-values/metrics-server.yaml")
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
      name      = "in-cluster"
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }
  }

  depends_on = [
    argocd_project.monitoring,
    argocd_repository.metrics-server,
  ]
}