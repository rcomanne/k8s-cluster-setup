resource "helm_release" "traefik" {
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"

  namespace        = "traefik"
  create_namespace = true
  name             = "traefik"
  version          = var.traefik_version

  values = [
    "${file("helm-values/traefik.yaml")}"
  ]

  depends_on = [
    helm_release.metallb,
    kubectl_manifest.metallb_ip_address_pool
  ]
}