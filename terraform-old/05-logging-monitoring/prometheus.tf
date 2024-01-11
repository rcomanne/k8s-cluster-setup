resource "argocd_repository" "prometheus" {
  repo = "https://prometheus-community.github.io/helm-charts"
  name = "prometheus-community"
  type = "helm"
}

#resource "argocd_application" "kube-prometheus-stack" {
#  metadata {
#    name      = "kube-prometheus-stack"
#    namespace = data.kubernetes_namespace.argo.metadata.0.name
#  }
#
#  spec {
#    project = argocd_project.monitoring.metadata.0.name
#    source {
#      repo_url        = argocd_repository.prometheus.repo
#      chart           = "kube-prometheus-stack"
#      target_revision = var.prometheus_version
#
#      helm {
#        values = file("helm-values/kube-prometheus-stack.yaml")
#      }
#    }
#
#    sync_policy {
#      automated {
#        allow_empty = false
#        prune       = true
#        self_heal   = true
#      }
#    }
#
#    destination {
#      name      = "in-cluster"
#      namespace = kubernetes_namespace.monitoring.metadata.0.name
#    }
#  }
#
#  depends_on = [
#    argocd_project.monitoring,
#    argocd_repository.prometheus
#  ]
#}