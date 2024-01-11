resource "argocd_project" "networking" {
  metadata {
    name      = "networking"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.metallb.metadata.0.name
    }

    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.traefik.metadata.0.name
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
    source_repos = [
      argocd_repository.metallb.repo,
      argocd_repository.traefik.repo,
    ]
  }
}

resource "argocd_project" "monitoring" {
  metadata {
    name      = "monitoring"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = "kube-system"
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
    source_repos = [
      argocd_repository.metrics-server.repo,
    ]
  }
}

resource "argocd_project" "databases" {
  metadata {
    name      = "databases"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.cnpg.metadata.0.name
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
      argocd_repository.cnpg.repo,
      argocd_repository.pgadmin.repo,
    ]
  }
}