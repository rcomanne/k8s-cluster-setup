resource "kubernetes_namespace" "fluent" {
  metadata {
    name = "fluent"
  }
}

resource "argocd_project" "fluent" {
  metadata {
    name      = "fluent"
    namespace = data.kubernetes_namespace.argo.metadata.0.name
  }

  spec {
    source_namespaces = ["argocd"]
    source_repos      = ["*"]

    destination {
      server    = "https://kubernetes.default.svc"
      name      = "in-cluster"
      namespace = kubernetes_namespace.fluent.metadata.0.name
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }
  }
}

resource "argocd_repository" "fluent" {
  repo    = "https://fluent.github.io/helm-charts"
  name    = "fluent"
  type    = "helm"
}

resource "argocd_application" "fluent-bit" {
  metadata {
    name      = "fluent-bit"
    namespace = data.kubernetes_namespace.argo.metadata.0.name
  }

  spec {
    project = argocd_project.fluent.metadata.0.name
    source {
      repo_url        = argocd_repository.fluent.repo
      chart           = "fluent-bit"
      target_revision = var.fluent_bit_version

      helm {
        values = file("helm-values/fluent-bit.yaml")
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
      namespace = kubernetes_namespace.fluent.metadata.0.name
    }
  }
}