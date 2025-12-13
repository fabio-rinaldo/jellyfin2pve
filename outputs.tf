output "container_id" {
  description = "The VMID of the created container"
  value       = proxmox_virtual_environment_container.jellyfin.vm_id
}

output "container_hostname" {
  description = "The hostname of the container"
  value       = proxmox_virtual_environment_container.jellyfin.initialization[0].hostname
}

output "network_config" {
  description = "Network configuration details"
  value = {
    (proxmox_virtual_environment_container.jellyfin.network_interface[0].name) = {
      ipv4    = var.iface_a_ip
    }
    (proxmox_virtual_environment_container.jellyfin.network_interface[1].name) = local.iface_b_enabled ? {
      ipv4    = var.iface_b_ip
    } : null
  }
}

output "resource_allocation" {
  description = "Container resource allocation"
  value = {
    cpu_cores = proxmox_virtual_environment_container.jellyfin.cpu[0].cores
    memory_mb = proxmox_virtual_environment_container.jellyfin.memory[0].dedicated
    disk_size = var.rootfs_size
  }
}
