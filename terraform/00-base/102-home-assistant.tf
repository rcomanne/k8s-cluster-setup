resource "kubernetes_namespace" "home_assistant" {
  metadata {
    name = "home-assistant"
  }
}

resource "argocd_application" "home_assistant" {
  metadata {
    name      = "home-assistant"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.applications.metadata.0.name
    source {
      repo_url = argocd_repository.k8s_deployments.repo
      path     = "home-assistant/overlays/homelab"
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
      namespace = kubernetes_namespace.home_assistant.metadata.0.name
    }
  }
}