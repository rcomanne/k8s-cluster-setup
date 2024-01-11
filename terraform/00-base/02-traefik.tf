resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "argocd_repository" "traefik" {
  repo = "https://traefik.github.io/charts"
  name = "traefik"
  type = "helm"
}

resource "argocd_application" "traefik" {
  metadata {
    name      = "traefik"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.networking.metadata.0.name
    source {
      repo_url        = argocd_repository.traefik.repo
      chart           = "traefik"
      target_revision = var.traefik_version

      helm {
        values = file("helm-values/traefik/values.yaml")
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
      namespace = kubernetes_namespace.traefik.metadata.0.name
    }
  }

  wait = true

  depends_on = [
    argocd_application.metallb
  ]
}

data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = kubernetes_namespace.traefik.metadata.0.name
  }

  depends_on = [
    argocd_application.traefik
  ]
}