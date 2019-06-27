resource "kubernetes_deployment" "service" {
  metadata {
    name = "service"

    labels = {
      test = "service"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "service"
      }
    }

    template {
      metadata {
        labels = {
          test = "service"
        }
      }

      spec {
        container {
          image = "${var.docker_registry_name}.azurecr.io/service:${var.buildno}"
          name  = "service"

          port {
            container_port = 80
          }

          env {
            name  = "DBHOST"
            value = "mongodb://db.default.svc.cluster.local:27017"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "service" {
  metadata {
    name = "service"
  }

  spec {
    selector = {
      test = kubernetes_deployment.service.metadata[0].labels.test
    }

    port {
      port        = 80
      target_port = 80
    }
  }
}

