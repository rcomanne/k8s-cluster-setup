resource "kubectl_manifest" "metallb_namespace" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: ${var.metallb_namespace}
  labels:
    kubernetes.io/metadata.name: metallb-system
    name: metallb-system
    pod-security.kubernetes.io/audit: privileged
    pod-security.kubernetes.io/enforce: privileged
    pod-security.kubernetes.io/warn: privileged
YAML
}

resource "helm_release" "metallb" {
  repository = "https://metallb.github.io/metallb"
  chart      = "metallb"

  namespace = var.metallb_namespace
  name      = "metallb"
  version   = var.metallb_version

  values = [
    "${file("helm-values/metallb.yaml")}"
  ]

  depends_on = [
    kubectl_manifest.metallb_namespace,
  ]
}

resource "kubectl_manifest" "metallb_ip_address_pool" {
  yaml_body          = "${file("manifests/metallb-ip-address-pool.yaml")}"
  override_namespace = var.metallb_namespace

  depends_on = [
    kubectl_manifest.metallb_namespace,
    helm_release.metallb,
  ]
}