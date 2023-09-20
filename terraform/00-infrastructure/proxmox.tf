resource "macaddress" "master_mac_addresses" {
}

resource "proxmox_vm_qemu" "master" {
  target_node = "pve"
  name        = "k8s-master"
  #  iso         = "local:iso/${var.iso_file}"
  clone       = var.clone_vm

  cpu    = "host"
  cores  = var.master_cpu_cores
  memory = var.master_memory

  onboot   = true
  boot     = "order=scsi0;net0"
  oncreate = true

  disk {
    type    = "scsi"
    storage = var.storage_name
    size    = var.master_storage_size
    format  = "raw"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = upper(macaddress.master_mac_addresses.address)
  }

  lifecycle {
    ignore_changes = [
      qemu_os
    ]
  }
}

resource "macaddress" "worker_mac_addresses" {
  count = var.worker_count
}

resource "proxmox_vm_qemu" "worker" {
  count = var.worker_count

  target_node = "pve"
  name        = "k8s-worker-${count.index}"
  #  iso         = "local:iso/${var.iso_file}"
  clone       = var.clone_vm

  cpu    = "host"
  cores  = var.worker_cpu_cores
  memory = var.worker_memory

  onboot   = false
  boot     = "order=scsi0;net0"
  oncreate = true

  disk {
    type    = "scsi"
    storage = var.storage_name
    size    = var.worker_storage_size
    format  = "raw"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = upper(macaddress.worker_mac_addresses[count.index].address)
  }

  lifecycle {
    ignore_changes = [
      qemu_os
    ]
  }
}