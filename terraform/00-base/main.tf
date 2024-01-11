data "azuread_client_config" "current" {}

resource "time_rotating" "password_rotation" {
  rotation_days = 60
}

resource "time_static" "password_rotation" {
  rfc3339 = time_rotating.password_rotation.rfc3339
}