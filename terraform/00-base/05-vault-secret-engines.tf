resource "vault_mount" "personal-accounts" {
  path = "personal-accounts"
  type = "kv-v2"
}

resource "vault_mount" "homelab" {
  path = "homelab"
  type = "kv-v2"
}

resource "vault_mount" "et" {
  path = "EfficientTransition"
  type = "kv-v2"
}