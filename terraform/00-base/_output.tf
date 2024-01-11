output "talosconfig" {
  value     = talos_machine_secrets.this.client_configuration
  sensitive = true
}

output "kubeconfig" {
  value     = data.talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "argocd_admin_password" {
  value     = random_password.argocd_admin.result
  sensitive = true
}

output "grafana_admin_password" {
  value     = random_password.grafana_admin.result
  sensitive = true
}