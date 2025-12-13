# Generate Ansible inventory from Terraform resources
# This creates a dynamic inventory file that stays in sync with infrastructure

locals {
  # Extract PVE host from endpoint (remove https:// and :port)
  pve_host = regex("https?://([^:]+)", var.proxmox_endpoint)[0]

  # Extract container IP from CIDR notation
  container_ip = split("/", var.iface_a_ip)[0]
}

resource "local_file" "ansible_inventory" {
  filename = "${path.module}/ansible/inventory/hosts.yml"

  content = templatefile("${path.module}/ansible/inventory/hosts.yml.tftpl", {
    pve_host          = local.pve_host
    container_id      = var.container_id
    container_ip      = local.container_ip
    nfs_server_ip     = var.nfs_server_ip
    nfs_export_video  = var.nfs_export_video
    nfs_export_music  = var.nfs_export_music
    nfs_mnt_dir_video = var.nfs_mnt_dir_video
    nfs_mnt_dir_music = var.nfs_mnt_dir_music
  })

  file_permission = "0644"
}
