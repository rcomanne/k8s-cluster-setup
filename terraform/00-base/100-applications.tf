resource "argocd_repository" "k8s_deployments" {
  repo = "https://github.com/rcomanne/k8s-deployments.git"
  name = "k8s-deployments"
  type = "git"
}

resource "argocd_project" "applications" {
  metadata {
    name      = "applications"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.mealie.metadata.0.name
    }
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.home_assistant.metadata.0.name
    }
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.nextcloud.metadata.0.name
    }

    cluster_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    namespace_resource_whitelist {
      group = "*"
      kind  = "*"
    }

    source_namespaces = ["*"]
    source_repos      = [
      argocd_repository.k8s_deployments.repo,
      argocd_repository.nextcloud.repo,
    ]
  }
}