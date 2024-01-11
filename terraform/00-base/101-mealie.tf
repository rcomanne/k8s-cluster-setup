resource "kubernetes_namespace" "mealie" {
  metadata {
    name = "mealie"
  }
}

resource "random_password" "mealie" {
  length = 32
}

resource "vault_kv_secret_v2" "mealie_postgres" {
  mount     = vault_mount.homelab.path
  name      = "mealie/postgres"
  data_json = jsonencode({
    username = "mealie"
    password = random_password.mealie.result
  })
}

resource "postgresql_role" "mealie" {
  name     = "mealie"
  login    = true
  password = random_password.mealie.result
}

resource "postgresql_database" "mealie" {
  name  = "mealie"
  owner = postgresql_role.mealie.name
}

locals {
  mealie_labels = {
    "app.kubernetes.io/name" = "mealie"
  }
}

resource "kubernetes_secret" "mealie" {
  metadata {
    name      = "mealie-database"
    namespace = kubernetes_namespace.mealie.metadata[0].name
  }
  type = "Opaque"

  data = {
    POSTGRES_SERVER   = "${local.postgres_name}-rw.${kubernetes_namespace.cnpg.metadata[0].name}.svc.cluster.local"
    POSTGRES_PORT     = "5432"
    POSTGRES_DB       = postgresql_database.mealie.name
    POSTGRES_USER     = postgresql_role.mealie.name
    POSTGRES_PASSWORD = postgresql_role.mealie.password
  }
}

resource "argocd_application" "mealie" {
  metadata {
    name      = "mealie"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    project = argocd_project.applications.metadata.0.name
    source {
      repo_url = argocd_repository.k8s_deployments.repo
      path     = "mealie/overlays/homelab"
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
      namespace = kubernetes_namespace.mealie.metadata.0.name
    }
  }
}

#resource "kubernetes_config_map" "mealie" {
#  metadata {
#    name      = "mealie"
#    namespace = kubernetes_namespace.mealie.metadata[0].name
#  }
#
#  data = {
#    ALLOW_SIGNUP    = "true"
#    PUID            = "1000"
#    PGID            = "1000"
#    TZ              = "Europe/Amsterdam"
#    MAX_WORKERS     = "1"
#    WEB_CONCURRENCY = "1"
#    BASE_URL        = "https://mealie.rcomanne.nl"
#    DB_ENGINE       = "postgres"
#    POSTGRES_SERVER = "${local.postgres_name}-rw.${kubernetes_namespace.cnpg.metadata[0].name}.svc.cluster.local"
#    POSTGRES_PORT   = "5432"
#  }
#}
#
#resource "kubernetes_deployment" "mealie" {
#  metadata {
#    name      = "mealie"
#    namespace = kubernetes_namespace.mealie.metadata[0].name
#  }
#
#  spec {
#    replicas = "1"
#
#    selector {
#      match_labels = local.mealie_labels
#    }
#
#    template {
#      metadata {
#        labels = local.mealie_labels
#      }
#
#      spec {
#        container {
#          name  = "mealie"
#          image = "ghcr.io/mealie-recipes/mealie:v1.0.0-RC2"
#
#          port {
#            name           = "web"
#            container_port = 9000
#          }
#
#          env_from {
#            config_map_ref {
#              name = kubernetes_config_map.mealie.metadata[0].name
#            }
#          }
#
#          env_from {
#            secret_ref {
#              name = kubernetes_secret.mealie.metadata[0].name
#            }
#          }
#
#          resources {
#            requests = {
#              cpu    = "100m"
#              memory = "500Mi"
#            }
#            limits = {
#              cpu    = "500m"
#              memory = "1000Mi"
#            }
#          }
#
#          volume_mount {
#            mount_path = "/app/data"
#            name       = "mealie-data"
#          }
#        }
#        volume {
#          name = "mealie-data"
#          empty_dir {}
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_service" "mealie" {
#  metadata {
#    name      = "mealie"
#    namespace = kubernetes_namespace.mealie.metadata[0].name
#  }
#
#  spec {
#    selector = local.mealie_labels
#
#    port {
#      name        = "web"
#      port        = 9000
#      target_port = "web"
#      protocol    = "TCP"
#    }
#
#    type = "ClusterIP"
#  }
#}
#
#resource "kubernetes_ingress_v1" "mealie" {
#  metadata {
#    name      = "mealie"
#    namespace = kubernetes_namespace.mealie.metadata[0].name
#    annotations = {
#      "traefik.ingress.kubernetes.io/router.entrypoints" = "websecure"
#    }
#  }
#
#  spec {
#    rule {
#      host = "mealie.rcomanne.nl"
#      http {
#        path {
#          path      = "/"
#          path_type = "Prefix"
#          backend {
#            service {
#              name = kubernetes_service.mealie.metadata[0].name
#              port {
#                name = "web"
#              }
#            }
#          }
#        }
#      }
#    }
#  }
#}