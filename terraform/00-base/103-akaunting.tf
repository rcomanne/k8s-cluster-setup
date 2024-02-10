#locals {
#  akaunting_admin_username = "akaunting"
#}
#
#resource "kubernetes_namespace" "akaunting" {
#  metadata {
#    name = "akaunting"
#  }
#}
#
#resource "random_password" "akaunting_admin" {
#  length = 16
#}
#
#resource "kubernetes_secret" "akaunting_admin" {
#  metadata {
#    name      = "akaunting-admin"
#    namespace = kubernetes_namespace.akaunting.metadata.0.name
#  }
#  type = "Opaque"
#
#  data = {
#    ADMIN_PASSWORD = random_password.akaunting_admin.result
#  }
#}
#
#resource "vault_kv_secret_v2" "akaunting_admin" {
#  mount = vault_mount.homelab.path
#  name  = "akaunting/admin"
#  data_json = jsonencode({
#    username = "info@cybercomanne.nl"
#    password = random_password.akaunting_admin.result
#  })
#}
#
#resource "random_password" "akaunting_postgres" {
#  length = 16
#}
#
#resource "kubernetes_secret" "akaunting_cnpg_postgres" {
#  metadata {
#    name      = "akaunting-cnpg-postgres"
#    namespace = kubernetes_namespace.akaunting.metadata.0.name
#  }
#  type = "kubernetes.io/basic-auth"
#
#  data = {
#    username = "akaunting"
#    password = random_password.akaunting_postgres.result
#  }
#}
#
#resource "vault_kv_secret_v2" "akaunting_postgres" {
#  mount = vault_mount.homelab.path
#  name  = "akaunting/postgres"
#  data_json = jsonencode({
#    username = "akaunting"
#    password = random_password.akaunting_postgres.result
#  })
#}
#
#resource "kubernetes_manifest" "akaunting_database" {
#  manifest = yamldecode(templatefile("${path.module}/manifests/cnpg/database_template.yaml", {
#    name         = kubernetes_namespace.akaunting.metadata.0.name,
#    namespace    = kubernetes_namespace.akaunting.metadata.0.name,
#    instances    = 1,
#    dbName       = kubernetes_namespace.akaunting.metadata.0.name,
#    dbOwner      = kubernetes_namespace.akaunting.metadata.0.name,
#    dbSecretName = kubernetes_secret.akaunting_cnpg_postgres.metadata.0.name,
#    size         = "8Gi"
#    storageClass = kubernetes_storage_class.nfs-csi-postgres.metadata.0.name,
#  }))
#}
#
#resource "kubernetes_secret" "akaunting_postgres" {
#  metadata {
#    name      = "akaunting-database"
#    namespace = kubernetes_namespace.akaunting.metadata.0.name
#  }
#  type = "Opaque"
#
#  data = {
#    DB_HOST     = "akaunting-rw"
#    DB_HOSTNAME = "akaunting-rw"
#    DB_PORT     = "5432"
#    DB_NAME     = "akaunting"
#    DB_USERNAME = "akaunting"
#    DB_PASSWORD = random_password.akaunting_postgres.result
#  }
#}
#
#resource "argocd_application" "akaunting" {
#  metadata {
#    name      = "akaunting"
#    namespace = helm_release.argo_cd.namespace
#  }
#
#  spec {
#    project = argocd_project.applications.metadata.0.name
#    source {
#      repo_url = argocd_repository.k8s_deployments.repo
#      path     = "akaunting/overlays/homelab"
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
#      namespace = kubernetes_namespace.akaunting.metadata.0.name
#    }
#  }
#}