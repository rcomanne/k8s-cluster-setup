resource "kubernetes_namespace" "metallb" {
  metadata {
    name   = "metallb-system"
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
    namespace = data.kubernetes_namespace.argo.metadata.name
  }

  spec {
    source {
      repo_url        = argocd_repository.metallb.repo
      chart           = "metallb"
      target_revision = var.metallb_version

      helm {
        values = file("helm-values/metallb.yaml")
      }
    }

    destination {
      namespace = kubernetes_namespace.metallb.metadata.0.name
    }
  }
}

resource "kubectl_manifest" "metallb_ip_address_pool" {
  yaml_body          = file("manifests/metallb-ip-address-pool.yaml")
  override_namespace = kubernetes_namespace.metallb.metadata.0.name

  depends_on = [
    kubernetes_namespace.metallb,
    argocd_application.metallb,
  ]
}