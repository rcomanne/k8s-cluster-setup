resource "kubernetes_namespace" "nextcloud" {
  metadata {
    name = "nextcloud"
  }
}

resource "argocd_repository" "nextcloud" {
  repo = "https://nextcloud.github.io/helm/"
  name = "nextcloud"
  type = "helm"
}

resource "random_password" "nextcloud_admin" {
  length = 16
}

resource "kubernetes_secret" "nextcloud_admin" {
  metadata {
    name      = "nextcloud-admin"
    namespace = kubernetes_namespace.nextcloud.metadata.0.name
  }
  type = "Opaque"

  data = {
    username = "nextcloud"
    password = random_password.nextcloud_admin.result
  }
}

resource "vault_kv_secret_v2" "nextcloud_admin" {
  mount     = vault_mount.homelab.path
  name      = "nextcloud/admin"
  data_json = jsonencode({
    username = "nextcloud"
    password = random_password.nextcloud_postgres.result
  })
}

resource "random_password" "nextcloud_postgres" {
  length = 16
}

resource "kubernetes_secret" "nextcloud_postgres" {
  metadata {
    name      = "nextcloud-postgres"
    namespace = kubernetes_namespace.nextcloud.metadata.0.name
  }
  type = "kubernetes.io/basic-auth"

  data = {
    username = "nextcloud"
    password = random_password.nextcloud_postgres.result
  }
}

resource "vault_kv_secret_v2" "nextcloud_postgres" {
  mount     = vault_mount.homelab.path
  name      = "nextcloud/postgres"
  data_json = jsonencode({
    username = "nextcloud"
    password = random_password.nextcloud_postgres.result
  })
}

resource "kubernetes_manifest" "nextcloud_database" {
  manifest = yamldecode(templatefile("${path.module}/manifests/nextcloud/database.yaml", {
    name         = kubernetes_namespace.nextcloud.metadata.0.name,
    namespace    = kubernetes_namespace.nextcloud.metadata.0.name,
    dbSecretName = kubernetes_secret.nextcloud_postgres.metadata.0.name
    storageClass = kubernetes_storage_class.nfs-csi-postgres.metadata.0.name,
  }))
}



resource "argocd_application" "nextcloud" {
  metadata {
    name      = "nextcloud"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.applications.metadata.0.name
    source {
      repo_url        = argocd_repository.nextcloud.repo
      chart           = "nextcloud"
      target_revision = var.nextcloud_version

      helm {
        values = file("helm-values/nextcloud/values.yaml")
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
      namespace = kubernetes_namespace.nextcloud.metadata.0.name
    }
  }
}