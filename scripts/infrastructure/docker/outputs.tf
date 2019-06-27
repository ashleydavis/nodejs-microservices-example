output "registry_name" {
  value = var.docker_registry_name
}

output "registry_hostname" {
  value = "${var.docker_registry_name}.azurecr.io"
}

output "docker_un" {
  value = azurerm_container_registry.docker_registry.admin_username
}

output "docker_pw" {
  value = azurerm_container_registry.docker_registry.admin_password
}

