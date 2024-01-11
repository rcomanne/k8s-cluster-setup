resource "kubernetes_namespace" "cnpg" {
  metadata {
    name = "cnpg-system"
  }
}

resource "argocd_repository" "cnpg" {
  repo = "https://cloudnative-pg.github.io/charts"
  name = "cnpg"
  type = "helm"
}

resource "kubernetes_storage_class" "nfs-csi-postgres" {
  metadata {
    name = "nfs-csi-postgres"
  }
  storage_provisioner = "nfs.csi.k8s.io"
  parameters = {
    server = "truenas.home"
    share  = "/mnt/habbo/nfs/rcomanne/postgres"
  }
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
  mount_options = [
    "nfsvers=4.1",
    "hard",
  ]
  allow_volume_expansion = true
}

resource "argocd_application" "cnpg" {
  metadata {
    name      = "cnpg"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.databases.metadata.0.name
    source {
      repo_url        = argocd_repository.cnpg.repo
      chart           = "cloudnative-pg"
      target_revision = var.cnpg_version

      helm {
        values = file("helm-values/cnpg/values.yaml")
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
      namespace = kubernetes_namespace.cnpg.metadata.0.name
    }
  }
}

locals {
  postgres_name = "postgres-cluster"
}

resource "random_password" "postgres" {
  length = 32

  lifecycle {
    replace_triggered_by = [
      time_static.password_rotation
    ]
  }
}

resource "vault_kv_secret_v2" "postgres_cluster" {
  mount     = vault_mount.homelab.path
  name      = "postgres"
  data_json = jsonencode({
    username = "postgres"
    password = random_password.postgres.result
  })
}

resource "kubernetes_manifest" "postgres_cluster" {
  manifest = yamldecode(templatefile("${path.module}/manifests/cnpg/cluster.yaml", {
    name         = local.postgres_name,
    namespace    = kubernetes_namespace.cnpg.metadata.0.name,
    storageClass = kubernetes_storage_class.nfs-csi-postgres.metadata.0.name,
  }))
}

resource "kubernetes_manifest" "postgres_cluster_ingress" {
  manifest = yamldecode(templatefile("${path.module}/manifests/cnpg/cluster_ingress.yaml", {
    name      = local.postgres_name,
    namespace = kubernetes_namespace.cnpg.metadata.0.name,
  }))
}

data "kubernetes_secret" "postgres_superuser" {
  metadata {
    name      = "${local.postgres_name}-superuser"
    namespace = kubernetes_namespace.cnpg.metadata.0.name
  }

  depends_on = [
    kubernetes_manifest.postgres_cluster
  ]
}

output "postgres_superuser" {
  value     = data.kubernetes_secret.postgres_superuser.data
  sensitive = true
}

resource "postgresql_database" "test" {
  name = "test"
}

resource "argocd_repository" "pgadmin" {
  repo = "https://helm.runix.net"
  name = "runix"
  type = "helm"
}

#resource "argocd_application" "pgadmin" {
#  metadata {
#    name      = "pgadmin"
#    namespace = helm_release.argo_cd.namespace
#  }
#
#  spec {
#    project = argocd_project.databases.metadata.0.name
#    source {
#      repo_url        = argocd_repository.pgadmin.repo
#      chart           = "pgadmin4"
#      target_revision = var.pgadmin_version
#
#      helm {
#        values = file("helm-values/cnpg/values.yaml")
#      }
#    }
#
#    sync_policy {
#      automated {
#        allow_empty = false
#        prune       = true
#        self_heal   = true
#      }
#    }
#
#    destination {
#      server    = local.argocd_cluster_server
#      namespace = kubernetes_namespace.cnpg.metadata.0.name
#    }
#  }
#}