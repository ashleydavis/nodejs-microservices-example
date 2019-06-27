output "client_key" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].username
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].password
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.main.kube_config_raw
}

output "host" {
  value = azurerm_kubernetes_cluster.main.kube_config[0].host
}

output "private_key" {
  value = tls_private_key.key.private_key_pem
}

output "public_key" {
  value = tls_private_key.key.public_key_pem
}

output "configure" {
  value = <<CONFIGURE

Run the following commands to configure the Kubernetes client:

$ terraform output kube_config > ~/.kube/aksconfig
$ export KUBECONFIG=~/.kube/aksconfig

Test configuration using kubectl:

$ kubectl get nodes
CONFIGURE

}

