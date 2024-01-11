resource "time_rotating" "argocd_admin" {
  rotation_days = 60
}

resource "random_password" "argocd_admin" {
  length  = 32
  special = false

  lifecycle {

  }
}

resource "azuread_application" "argo_cd" {
  display_name = "homelab-argo-cd"
  owners       = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = [
      "http://localhost:8085/auth/callback",
      "https://${local.argo_cd_host}/auth/callback",
    ]
  }

  optional_claims {
    access_token {
      name      = "groups"
      essential = true
    }
    id_token {
      name      = "groups"
      essential = true
    }
  }

  group_membership_claims = ["SecurityGroup"]

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    // User.Read
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

resource "time_rotating" "argo_cd" {
  rotation_days = 90
}

resource "azuread_group" "argocd_admin" {
  display_name     = "argocd-admin"
  owners           = [data.azuread_client_config.current.object_id]
  security_enabled = true

  members = local.argocd_admins
}

resource "azuread_service_principal" "argo_cd" {
  client_id = azuread_application.argo_cd.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal_password" "argo_cd" {
  service_principal_id = azuread_service_principal.argo_cd.object_id
  rotate_when_changed = {
    rotate = time_rotating.argo_cd.id
  }
}

resource "helm_release" "argo_cd" {
  repository = local.argo_repository
  chart      = "argo-cd"

  namespace        = "argocd"
  create_namespace = true
  name             = "argocd"
  version          = var.argo_cd_version

  // Weird formatting does not behave as expected in the values.yaml file...
  set {
    name  = "configs.params.server\\.insecure"
    value = true
  }

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = random_password.argocd_admin.bcrypt_hash
  }

  set_sensitive {
    name  = "configs.secret.extra.oidc\\.azure\\.clientSecret"
    value = azuread_service_principal_password.argo_cd.value
  }

  values = [
    templatefile("${path.module}/helm-values/argo-cd/values.yaml", {
      argo_cd_host        = local.argo_cd_host,
      directory_tenant_id = data.azuread_client_config.current.tenant_id
      oidc_client_id      = azuread_application.argo_cd.client_id
      oidc_admin_group_id = azuread_group.argocd_admin.object_id
    })
  ]

  cleanup_on_fail = true
  wait            = true
}