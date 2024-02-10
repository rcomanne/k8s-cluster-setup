resource "kubernetes_namespace" "prometheus" {
  metadata {
    name = "prometheus"
    labels = {
      "pod-security.kubernetes.io/enforce" = "privileged"
    }
  }
}

resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

resource "argocd_repository" "prometheus_community" {
  repo = "https://prometheus-community.github.io/helm-charts"
  name = "prometheus-community"
  type = "helm"
}

resource "argocd_repository" "grafana" {
  repo = "https://grafana.github.io/helm-charts"
  name = "grafana"
  type = "helm"
}

resource "argocd_project" "prometheus" {
  metadata {
    name      = "prometheus"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.prometheus.metadata.0.name
    }

    destination {
      name      = "in-cluster"
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.grafana.metadata.0.name
    }

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
      argocd_repository.k8s_deployments.repo,
      argocd_repository.prometheus_community.repo,
    ]
  }
}

resource "random_password" "grafana_admin" {
  length = 16

  lifecycle {
    replace_triggered_by = [
      time_static.password_rotation
    ]
  }
}

resource "vault_kv_secret_v2" "grafana_admin" {
  mount = vault_mount.homelab.path
  name  = "grafana"
  data_json = jsonencode({
    admin = random_password.grafana_admin.result
  })
}

resource "argocd_application" "kube_prometheus_stack" {
  metadata {
    name      = "kube-prometheus-stack"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.prometheus.metadata.0.name
    source {
      repo_url        = argocd_repository.prometheus_community.repo
      chart           = "kube-prometheus-stack"
      target_revision = var.kube_prometheus_stack_version

      helm {
        value_files = ["$values/kube-prometheus-stack/values.yaml"]
        parameter {
          name  = "grafana.adminPassword"
          value = random_password.grafana_admin.result
        }
      }
    }

    source {
      repo_url = argocd_repository.k8s_deployments.repo
      ref      = "values"
    }

    sync_policy {
      automated {
        prune       = true
        self_heal   = true
        allow_empty = true
      }
      sync_options = [
        "ServerSideApply=true"
      ]
    }

    destination {
      server    = local.argocd_cluster_server
      namespace = kubernetes_namespace.prometheus.metadata.0.name
    }
  }

  depends_on = [
    argocd_project.prometheus,
    argocd_repository.prometheus_community,
  ]
}