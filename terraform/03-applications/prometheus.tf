resource "argocd_repository" "prometheus" {
  repo = "https://prometheus-community.github.io/helm-charts"
  name = "prometheus-community"
  type = "helm"
}

resource "argocd_application" "kube-prometheus-stack" {
  metadata {
    name      = "kube-prometheus-stack"
    namespace = data.kubernetes_namespace.argo.metadata.name
  }

  spec {
    source {
      repo_url        = argocd_repository.prometheus.repo
      chart           = "kube-prometheus-stack"
      target_revision = "51.0.3"

      helm {
        values = file("helm-values/kube-prometheus-stack.yaml")
      }
    }

    destination {
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }
  }
}

resource "argocd_application" "metrics-server" {
  metadata {
    name      = "metrics-server"
    namespace = data.kubernetes_namespace.argo.metadata.name
  }

  spec {
    destination {
      namespace = kubernetes_namespace.monitoring.metadata.0.name
    }

    source {
      repo_url        = argocd_repository.metrics-server.repo
      chart           = "metrics-server"
      target_revision = "3.11.0"

      helm {
        values = file("helm-values/metrics-server.yaml")
      }
    }
  }
}