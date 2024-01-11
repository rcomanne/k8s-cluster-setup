resource "kubernetes_namespace" "metallb" {
  metadata {
    name = "metallb-system"
    labels = {
      "pod-security.kubernetes.io/audit"   = "privileged"
      "pod-security.kubernetes.io/enforce" = "privileged"
      "pod-security.kubernetes.io/warn"    = "privileged"
    }
  }
}

resource "argocd_repository" "metallb" {
  repo = "https://metallb.github.io/metallb"
  name = "metallb"
  type = "helm"
}

resource "argocd_application" "metallb" {
  metadata {
    name      = "metallb"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.networking.metadata.0.name
    source {
      repo_url        = argocd_repository.metallb.repo
      chart           = "metallb"
      target_revision = var.metallb_version

      helm {
        values = file("${path.module}/helm-values/metallb/values.yaml")
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
      namespace = kubernetes_namespace.metallb.metadata.0.name
    }
  }
}

resource "kubernetes_manifest" "metallb_ip_address_pool" {
  depends_on = [
    kubernetes_namespace.metallb,
    argocd_application.metallb,
  ]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind = "IPAddressPool"
    metadata = {
      name = "default-pool"
      namespace = kubernetes_namespace.metallb.metadata.0.name
    }
    spec = {
      addresses = [
        "192.168.2.240-192.168.2.250"
      ]
    }
  }
}

resource "kubernetes_manifest" "metallb_advertisement" {
  depends_on = [
    kubernetes_namespace.metallb,
    argocd_application.metallb,
  ]

  manifest = {
    apiVersion = "metallb.io/v1beta1"
    kind = "L2Advertisement"
    metadata = {
      name = "default-advertisement"
      namespace = kubernetes_namespace.metallb.metadata.0.name
    }
    spec = {}
  }
}
