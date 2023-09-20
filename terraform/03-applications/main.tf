data "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "argocd_project" "monitoring" {
  metadata {
    name      = "monitoring"
    namespace = data.kubernetes_namespace.argo.metadata.name
  }

  spec {
    destination {
      namespace = "monitoring"
    }

    source_namespaces = [
      kubernetes_namespace.monitoring.metadata.0.name
    ]
    source_repos = [
      argocd_repository.metrics-server.repo
    ]
  }
}