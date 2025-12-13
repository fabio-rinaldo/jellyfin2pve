######################
### PVE CONNECTION ###
######################

variable "proxmox_endpoint" {
  description = "Proxmox API endpoint (e.g., https://192.168.1.100:8006)"
  type        = string
}

variable "proxmox_insecure" {
  description = "Skip TLS verification for Proxmox API"
  type        = bool
  default     = false
}

variable "proxmox_node" {
  description = "Proxmox node name where the container will be created"
  type        = string
}

###################
### LXC OPTIONS ###
###################

variable "container_id" {
  description = "Container VMID"
  type        = number
  validation {
    condition     = var.container_id >= 100 && var.container_id <= 999999
    error_message = "Container ID must be between 100 and 999999."
  }
}

variable "container_hostname" {
  description = "Container hostname"
  type        = string
  default     = "jellyfin"
}

variable "container_description" {
  description = "Container description"
  type        = string
  default     = "Debian LXC for Jellyfin media server"
}

variable "container_swap" {
  description = "Swap memory in MB"
  type        = number
  default     = 0
}

variable "start_on_boot" {
  description = "Start container on boot"
  type        = bool
  default     = false
}

variable "startup_order" {
  description = "Order in boot sequence"
  type        = number
  default     = null
  nullable    = true
}

variable "startup_updelay" {
  description = "Boot delay of subsequent VMs in the boot sequence (in seconds)"
  type        = number
  default     = null
  nullable    = true
}

variable "startup_downdelay" {
  description = "Graceful shutdown timeout (in seconds)"
  type        = number
  default     = null
  nullable    = true
}

variable "unprivileged" {
  description = "Create unprivileged container"
  type        = bool
  default     = true
}

##########################
### RESOURCE ALLOCATION ##
##########################

variable "container_cpu_cores" {
  description = "Number of CPU cores allocated to the container"
  type        = number
  default     = 4
}

variable "container_memory" {
  description = "Memory allocated to the container in MB"
  type        = number
  default     = 4096
}

###################
### LXC STORAGE ###
###################

variable "disk_storage_pool" {
  description = "Storage pool for the container rootfs"
  type        = string
}

variable "rootfs_size" {
  description = "Root filesystem size (in GB')"
  type        = number
  default     = "16"
}

####################
### LXC TEMPLATE ###
####################

variable "template_storage_pool" {
  description = "Storage pool for the container template"
  type        = string
}

variable "template_name" {
  description = "Container template name (e.g., 'debian-13-standard_13.0-1_amd64.tar.zst')"
  type        = string
  default     = "debian-13-standard_13.1-2_amd64.tar.zst"
}

###################
### LXC NETWORK ###
###################

# Interface A
variable "iface_a_label" {
  description = "Network interface name"
  type        = string
  default     = "eth0"
}

variable "iface_a_bridge" {
  description = "Proxmox bridge (e.g., 'vmbr0')"
  type        = string
}

variable "iface_a_vlan" {
  description = "VLAN ID (null for no VLAN tagging)"
  type        = number
  default     = null
  nullable    = true
}

variable "iface_a_ip" {
  description = "IP address (e.g., '192.168.1.100/24')"
  type        = string
}

variable "iface_a_gateway" {
  description = "Gateway"
  type        = string
  default     = null
  nullable    = true
}

# Interface B (Optional)
variable "iface_b_label" {
  description = "Network interface name"
  type        = string
  default     = "eth1"
}

variable "iface_b_bridge" {
  description = "Proxmox bridge (e.g., 'vmbr1')"
  type        = string
  default     = null
  nullable    = true
}

variable "iface_b_vlan" {
  description = "VLAN ID (null for no VLAN tagging)"
  type        = number
  default     = null
  nullable    = true
}

variable "iface_b_ip" {
  description = "IP address (e.g., '192.168.2.100/24')"
  type        = string
  default     = null
  nullable    = true
}

variable "iface_b_gateway" {
  description = "Gateway"
  type        = string
  default     = null
  nullable    = true
}

# DNS Configuration
variable "dns_servers" {
  description = "List of DNS server IP addresses"
  type        = list(string)
}

###########
### NAS ###
###########

variable "nfs_server_ip" {
  description = "IP address of NFS server"
  type        = string
}

variable "nfs_export_video" {
  description = "Export path for 'video' folder on NFS server"
  type        = string
}

variable "nfs_export_music" {
  description = "Export path for 'music' folder on NFS server"
  type        = string
}

variable "nfs_mnt_dir_video" {
  description = "Path to mount 'video' folder on PVE host and inside LXC"
  type        = string
}

variable "nfs_mnt_dir_music" {
  description = "Path to mount 'music' folder on PVE host and inside LXC"
  type        = string
}

###############
### SECRETS ###
###############

# Proxmox API Token
#
# Format: username@realm!tokenid=secret
# Example: root@pam!terraform=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
#
# To create an API token in Proxmox:
# 1. Login to Proxmox web UI
# 2. Go to Datacenter > Permissions > API Tokens
# 3. Click "Add" and create a token for your user
# 4. IMPORTANT: Uncheck "Privilege Separation" to use user's permissions
# 5. Copy the token secret (shown only once!)
# 6. Format the token as: username@realm!tokenid=secret
variable "proxmox_api_token" {
  description = "Proxmox API token (format: user@realm!tokenid=secret)"
  type        = string
  sensitive   = true
}

# Container Root Password
#
# You can use either:
# 1. Plaintext password (will be hashed by Proxmox)
# 2. Pre-hashed password (more secure)
#
# To generate a hashed password (SHA-512):
#   mkpasswd -m sha-512 "your-password-here"
# Or using openssl:
#   openssl passwd -6 "your-password-here"
#
# Example plaintext:
#   container_root_password = "MySecurePassword123!"
# Example hashed (SHA-512):
#   container_root_password = "$6$rounds=5000$saltsalt$hashhash..."
variable "container_root_password" {
  description = "Root user password for the container (plaintext or hashed)"
  type        = string
  sensitive   = true
}

# Container SSH Public Keys (Optional)
#
# Add your SSH public keys for passwordless authentication.
# You can find your public key at: ~/.ssh/id_rsa.pub or ~/.ssh/id_ed25519.pub
#
# Example:
#   container_ssh_keys = [
#     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... user@host",
#     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host2"
#   ]
variable "container_ssh_keys" {
  description = "List of SSH public keys for root user (optional)"
  type        = list(string)
  default     = []
}

########################
### ANSIBLE SETTINGS ###
########################

variable "ansible_auto_execute" {
  description = "Automatically run Ansible playbook after Terraform provisioning"
  type        = bool
  default     = true
}
