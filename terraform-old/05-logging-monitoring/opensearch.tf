resource "kubernetes_namespace" "opensearch" {
  metadata {
    name = "opensearch"
  }
}

resource "argocd_repository" "opensearch" {
  repo = "https://opensearch-project.github.io/helm-charts/"
  name = "opensearch"
  type = "helm"
}

resource "argocd_application" "opensearch" {
  metadata {
    name      = "opensearch"
    namespace = data.kubernetes_namespace.argo.metadata.0.name
  }

  spec {
    project = argocd_project.monitoring.metadata.0.name
    source {
      repo_url        = argocd_repository.opensearch.repo
      chart           = "opensearch"
      target_revision = var.opensearch_version

      helm {
        values = file("helm-values/opensearch.yaml")
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
      namespace = kubernetes_namespace.opensearch.metadata.0.name
    }
  }

  depends_on = [
    argocd_project.monitoring,
    argocd_repository.opensearch,
  ]
}

resource "argocd_application" "opensearch-dashboards" {
  metadata {
    name      = "opensearch-dashboards"
    namespace = data.kubernetes_namespace.argo.metadata.0.name
  }

  spec {
    project = argocd_project.monitoring.metadata.0.name
    source {
      repo_url        = argocd_repository.opensearch.repo
      chart           = "opensearch-dashboards"
      target_revision = var.opensearch_dashboards_version

      helm {
        values = file("helm-values/opensearch-dashboards.yaml")
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
      namespace = kubernetes_namespace.opensearch.metadata.0.name
    }
  }

  depends_on = [
    argocd_project.monitoring,
    argocd_repository.opensearch,
  ]
}