data "kubernetes_namespace" "argo" {
  metadata {
    name = "argocd"
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
    namespace = data.kubernetes_namespace.argo.metadata.0.name
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = "https://kubernets.default.svc"
      namespace = "kube-system"
    }
    destination {
      name      = "in-cluster"
      server    = "https://kubernets.default.svc"
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }
    destination {
      name      = "in-cluster"
      server    = "https://kubernets.default.svc"
      namespace = kubernetes_namespace.opensearch.metadata.0.name
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }
    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    source_namespaces = [
      kubernetes_namespace.monitoring.metadata.0.name,
    ]
    source_repos = [
      argocd_repository.metrics-server.repo,
      argocd_repository.prometheus.repo,
      argocd_repository.opensearch.repo,
    ]
  }
}