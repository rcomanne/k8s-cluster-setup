data "kubernetes_namespace" "argo" {
  metadata {
    name = "argo"
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
      kubernetes_namespace.traefik.metadata.0.name
    ]
    source_repos = [
      argocd_repository.traefik.repo
    ]
  }
}