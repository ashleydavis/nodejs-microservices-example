resource "kubernetes_deployment" "db" {
  metadata {
    name = "db"

    labels = {
      test = "db"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        test = "db"
      }
    }

    template {
      metadata {
        labels = {
          test = "db"
        }
      }

      spec {
        container {
          image = "mongo"
          name  = "db"

          port {
            container_port = 27017
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "db" {
  metadata {
    name = "db"
  }

  spec {
    selector = {
      test = kubernetes_deployment.db.metadata[0].labels.test
    }

    port {
      port        = 27017
      target_port = 27017
    }
  }
}

