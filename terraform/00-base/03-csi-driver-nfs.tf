resource "argocd_repository" "csi-driver-nfs" {
  repo = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  name = "csi-driver-nfs"
  type = "helm"
}

resource "argocd_application" "csi-driver-nfs" {
  metadata {
    name      = "csi-driver-nfs"
    namespace = helm_release.argo_cd.namespace
  }

  spec {
    source {
      repo_url        = argocd_repository.csi-driver-nfs.repo
      chart           = "csi-driver-nfs"
      target_revision = var.csi_driver_nfs_version

      helm {
        values = file("helm-values/csi-driver-nfs/values.yaml")
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
      namespace = "kube-system"
    }
  }

  depends_on = [
    argocd_repository.csi-driver-nfs,
  ]

  wait = true
}

resource "kubernetes_storage_class" "nfs-csi" {
  metadata {
    name = "nfs-csi"
  }
  storage_provisioner = "nfs.csi.k8s.io"
  parameters = {
    server = "truenas.home"
    share  = "/mnt/habbo/nfs/rcomanne"
  }
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
  mount_options = [
    "nfsvers=4.1",
    "hard",
  ]
  allow_volume_expansion = true
}

resource "kubernetes_storage_class" "nfs-csi-default" {
  metadata {
    name = "nfs-csi-default"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }
  storage_provisioner = "nfs.csi.k8s.io"
  parameters = {
    server = "truenas.home"
    share  = "/mnt/habbo/nfs/rcomanne/default"
  }
  reclaim_policy      = "Retain"
  volume_binding_mode = "Immediate"
  mount_options = [
    "nfsvers=4.1",
    "hard",
  ]
  allow_volume_expansion = true
}