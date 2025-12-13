resource "null_resource" "ansible_playbook" {
  # Only create this resource if auto-execution is enabled
  count = var.ansible_auto_execute ? 1 : 0

  depends_on = [
    proxmox_virtual_environment_container.jellyfin,
    local_file.ansible_inventory
  ]

  triggers = {
    # Run every time
    always_run = timestamp()
  }

  # Execute the Ansible playbook
  provisioner "local-exec" {
    command     = "ansible-playbook deploy-jellyfin.yml"
    working_dir = "${path.module}/ansible"
  }
}
