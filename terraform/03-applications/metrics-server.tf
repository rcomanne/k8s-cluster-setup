resource "argocd_repository" "metrics-server" {
  repo = "https://kubernetes-sigs.github.io/metrics-server/"
  name = "metrics-server"
  type = "helm"
}

resource "argocd_application" "metrics-server" {
  metadata {
    name      = "metrics-server"
    namespace = data.kubernetes_namespace.argo.metadata.name
  }

  spec {
    source {
      repo_url        = argocd_repository.metrics-server.repo
      chart           = "metrics-server"
      target_revision = "3.11.0"

      helm {
        values = file("helm-values/metrics-server.yaml")
      }
    }

    destination {
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }
  }
}