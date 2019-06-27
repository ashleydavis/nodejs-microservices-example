provider "azurerm" {
}

resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}-${var.environment}"
  location = var.location
}

# Generate an SSH key.
# See video: https://channel9.msdn.com/Shows/Azure-Friday/Provisioning-Kubernetes-clusters-on-AKS-using-HashiCorp-Terraform?utm_source=newsletter&utm_medium=email&utm_campaign=Learn%20By%20Doing
# At time: 3:15, 4:50 
resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.cluster_name}-${var.environment}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "${var.dns_prefix}-${var.environment}"

  linux_profile {
    admin_username = var.admin_username

    ssh_key {
      key_data = "${trimspace(tls_private_key.key.public_key_openssh)} ${var.admin_username}@azure.com"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = var.agent_count
    vm_size         = "Standard_B2s"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.client_id
    client_secret = var.client_secret
  }

  tags = {
    Environment = "Production"
  }
}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.main.kube_config[0].host

  #username               = "${azurerm_kubernetes_cluster.main.kube_config.0.username}"
  #password               = "${azurerm_kubernetes_cluster.main.kube_config.0.password}"
  client_certificate = base64decode(
    azurerm_kubernetes_cluster.main.kube_config[0].client_certificate,
  )

  client_key = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(
    azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate,
  )
}

