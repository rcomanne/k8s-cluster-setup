provider "proxmox" {
  pm_api_url      = "https://pve.home:8006/api2/json"
  pm_tls_insecure = true

  pm_log_enable = true
  pm_debug      = true
}