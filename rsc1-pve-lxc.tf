locals {
  # Determine if interface B is enabled
  iface_b_enabled = var.iface_b_bridge != null && var.iface_b_ip != null

  # Count gateways
  gateway_count = (
    (var.iface_a_gateway != null ? 1 : 0) +
    (local.iface_b_enabled && var.iface_b_gateway != null ? 1 : 0)
  )
}

resource "proxmox_virtual_environment_container" "jellyfin" {
  description = var.container_description
  node_name   = var.proxmox_node
  vm_id       = var.container_id

  lifecycle {
    precondition {
      condition     = local.gateway_count <= 1
      error_message = "Only one gateway can be defined across all interfaces. Found gateways on: ${var.iface_a_gateway != null ? "iface_a" : ""}${var.iface_a_gateway != null && var.iface_b_gateway != null ? " and " : ""}${var.iface_b_gateway != null ? "iface_b" : ""}"
    }
  }

  # Options
  started       = false # Don't autostart after creation
  start_on_boot = var.start_on_boot

  startup {
    order      = var.startup_order
    up_delay   = var.startup_updelay
    down_delay = var.startup_downdelay
  }

  unprivileged = false

  features {
    nesting = false
  }

  operating_system {
    template_file_id = "${var.template_storage_pool}:vztmpl/${var.template_name}"
    type             = "debian"
  }

  cpu {
    cores = var.container_cpu_cores
  }

  memory {
    dedicated = var.container_memory
    swap      = var.container_swap
  }

  disk {
    datastore_id = var.disk_storage_pool
    size         = var.rootfs_size
  }

  # Network Interface A
  network_interface {
    name    = var.iface_a_label
    bridge  = var.iface_a_bridge
    vlan_id = var.iface_a_vlan
    enabled = true
  }

  # Network Interface B (Optional)
  dynamic "network_interface" {
    for_each = local.iface_b_enabled ? [1] : []
    content {
      name    = var.iface_b_label
      bridge  = var.iface_b_bridge
      vlan_id = var.iface_b_vlan
      enabled = true
    }
  }

  initialization {
    hostname = var.container_hostname

    # IP Configuration for Interface A
    ip_config {
      ipv4 {
        address = var.iface_a_ip
        gateway = var.iface_a_gateway
      }
    }

    # IP Configuration for Interface B (Optional)
    dynamic "ip_config" {
      for_each = local.iface_b_enabled ? [1] : []
      content {
        ipv4 {
          address = var.iface_b_ip
          gateway = var.iface_b_gateway
        }
      }
    }

    user_account {
      keys     = var.container_ssh_keys
      password = var.container_root_password
    }

    dns {
      servers = var.dns_servers
    }
  }
}

resource "proxmox_virtual_environment_firewall_rules" "inbound" {
  depends_on = [
    proxmox_virtual_environment_container.jellyfin,
  ]

  node_name = proxmox_virtual_environment_container.jellyfin.node_name
  vm_id     = proxmox_virtual_environment_container.jellyfin.vm_id

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow SSH"
    dest    = split("/", var.iface_a_ip)[0]
    dport   = "22"
    proto   = "tcp"
    log     = "nolog"
  }

  rule {
    type    = "in"
    action  = "ACCEPT"
    comment = "Allow HTTP to jellyfin"
    dest    = split("/", var.iface_a_ip)[0]
    dport   = "8096"
    proto   = "tcp"
    log     = "nolog"
  }

  dynamic "rule" {
    for_each = local.iface_b_enabled ? [1] : []
    content {
      type    = "in"
      action  = "ACCEPT"
      comment = "Allow HTTP to jellyfin"
      dest    = split("/", var.iface_b_ip)[0]
      dport   = "8096"
      proto   = "tcp"
      log     = "nolog"
    }
  }
}
