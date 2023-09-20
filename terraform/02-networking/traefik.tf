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
    namespace = data.kubernetes_namespace.argo.metadata.name
  }

  spec {
    source {
      repo_url        = argocd_repository.traefik.repo
      chart           = "traefik"
      target_revision = var.traefik_version

      helm {
        values = file("helm-values/traefik.yaml")
      }
    }

    destination {
      namespace = kubernetes_namespace.traefik.metadata.0.name
    }
  }
}