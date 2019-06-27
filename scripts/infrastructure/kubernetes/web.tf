resource "azurerm_public_ip" "web" {
  name                = "web-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = "MC_${azurerm_resource_group.main.name}_${azurerm_kubernetes_cluster.main.name}_${azurerm_kubernetes_cluster.main.location}"
  allocation_method   = "Static"
}

output "web_ip" {
  value = azurerm_public_ip.web.ip_address
}

resource "kubernetes_deployment" "web" {
  metadata {
    name = "web"

    labels = {
      test = "web"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "web"
      }
    }

    template {
      metadata {
        labels = {
          test = "web"
        }
      }

      spec {
        container {
          image = "${var.docker_registry_name}.azurecr.io/web:${var.buildno}"
          name  = "web"

          port {
            container_port = 80
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "web"
  }

  spec {
    selector = {
      test = kubernetes_deployment.web.metadata[0].labels.test
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type             = "LoadBalancer"
    load_balancer_ip = azurerm_public_ip.web.ip_address
  }
}

