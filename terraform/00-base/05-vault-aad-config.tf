resource "vault_policy" "admin" {
  name   = "admin"
  policy = file("vault-policies/admin.hcl")
}

resource "vault_policy" "super-admin" {
  name   = "super-admin"
  policy = file("vault-policies/super-admin.hcl")
}

resource "azuread_application" "vault" {
  display_name = "homelab-vault"
  owners       = [data.azuread_client_config.current.object_id]

  web {
    redirect_uris = [
      "http://localhost:8250/oidc/callback",
      "https://${local.vault_host}/ui/vault/auth/oidc/oidc/callback",
    ]
  }

  group_membership_claims = ["All"]
  optional_claims {
    id_token {
      name = "email"
    }
    id_token {
      name = "groups"
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000"

    // email
    resource_access {
      id   = "64a6cdd6-aab1-4aaf-94b8-3cc8405e90d0"
      type = "Scope"
    }
    // User.Read
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
    // Group.Read.All
    resource_access {
      id   = "5b567255-7703-4780-807c-7be8301ae99b"
      type = "Role"
    }

  }
}


resource "azuread_service_principal" "vault" {
  client_id = azuread_application.vault.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

resource "time_rotating" "vault" {
  rotation_days = 90
}

resource "azuread_service_principal_password" "vault" {
  service_principal_id = azuread_service_principal.vault.object_id
  rotate_when_changed = {
    rotation = time_rotating.vault.id
  }
}

resource "vault_jwt_auth_backend" "oidc" {
  description = "Login to Vault with AAD"
  path        = "oidc"
  type        = "oidc"

  oidc_discovery_url = "https://login.microsoftonline.com/${data.azuread_client_config.current.tenant_id}/v2.0"
  oidc_client_id     = azuread_application.vault.client_id
  oidc_client_secret = azuread_service_principal_password.vault.value

  provider_config = {
    "provider" = "azure"
  }

  default_role = "aad_role"

  tune {
    default_lease_ttl = "2h"
    max_lease_ttl     = "6h"
    token_type        = "default-service"
  }
}

resource "vault_jwt_auth_backend_role" "aad_role" {
  backend      = vault_jwt_auth_backend.oidc.path
  role_name    = "aad_role"
  user_claim   = "oid"
  groups_claim = "groups"

  token_policies = [
    "default"
  ]

  allowed_redirect_uris = [
    "http://localhost:8250/oidc/callback",
    "https://${local.vault_host}/ui/vault/auth/oidc/oidc/callback"
  ]

  oidc_scopes = [
    "https://graph.microsoft.com/.default",
    "profile"
  ]
}

resource "vault_identity_entity" "admin" {
  name = "admin"
  policies = [
    vault_policy.super-admin.name
  ]
}

resource "vault_identity_entity_alias" "admin" {
  mount_accessor = vault_jwt_auth_backend.oidc.accessor
  canonical_id   = vault_identity_entity.admin.id
  name           = data.azuread_user.default_admin.object_id

  depends_on = [
    vault_jwt_auth_backend.oidc
  ]
}
