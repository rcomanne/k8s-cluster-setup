locals {
  master_ips       = [for master in var.masters : master.ip_address]
  cluster_name     = "talos-homelab"
  cluster_endpoint = "https://${local.master_ips[0]}:6443"
}

resource "talos_machine_secrets" "this" {}

data "talos_machine_configuration" "controlplane" {
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_machine_configuration" "worker" {
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.master_ips
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_vm_qemu.master
  ]

  for_each = var.masters

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  node                        = each.value.ip_address
  config_patches = [
    templatefile("${path.module}/templates/talos-node-configuration.yaml", {
      hostname = each.key
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    proxmox_vm_qemu.worker
  ]

  for_each = var.workers

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  node                        = each.value.ip_address
  config_patches = [
    templatefile("${path.module}/templates/talos-node-configuration.yaml", {
      hostname = each.key
    })
  ]
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.master_ips[0]
}

data "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.master_ips[0]
}