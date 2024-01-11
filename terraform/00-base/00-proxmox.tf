resource "proxmox_vm_qemu" "master" {
  for_each = var.masters

  target_node = "pve"
  name        = each.key
  iso         = var.iso_file

  cpu    = "host"
  cores  = each.value.cpu_cores
  memory = each.value.memory

  onboot = true
  #  boot     = "order=scsi0;net0"
  oncreate = true

  disk {
    type    = "sata"
    storage = each.value.storage_name
    size    = each.value.storage_size
    format  = "qcow2"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = each.value.mac_address
  }

  lifecycle {
    ignore_changes = [
      qemu_os
    ]
  }
}

resource "proxmox_vm_qemu" "worker" {
  for_each = var.workers

  target_node = "pve"
  name        = each.key
  iso         = var.iso_file

  cpu    = "host"
  cores  = each.value.cpu_cores
  memory = each.value.memory

  onboot   = true
  oncreate = true
  #  boot     = "order=scsi0;net0"

  disk {
    type    = "sata"
    storage = each.value.storage_name
    size    = each.value.storage_size
    format  = "qcow2"
  }

  network {
    model    = "virtio"
    bridge   = "vmbr0"
    firewall = false
    macaddr  = each.value.mac_address
  }

  lifecycle {
    ignore_changes = [
      qemu_os
    ]
  }
}