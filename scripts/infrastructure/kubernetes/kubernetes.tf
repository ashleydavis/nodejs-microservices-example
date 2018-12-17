provider "azurerm" {}

resource "azurerm_resource_group" "main" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  dns_prefix          = "${var.dns_prefix}"

  linux_profile {
    #Todo: can pull adminusername from variables.
    admin_username = "ubuntu"

    # todo: This ssh_key can be generated.
    # See video: https://channel9.msdn.com/Shows/Azure-Friday/Provisioning-Kubernetes-clusters-on-AKS-using-HashiCorp-Terraform?utm_source=newsletter&utm_medium=email&utm_campaign=Learn%20By%20Doing
    # At time: 3:15, 4:50 
    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCqaZoyiz1qbdOQ8xEf6uEu1cCwYowo5FHtsBhqLoDnnp7KUTEBN+L2NxRIfQ781rxV6Iq5jSav6b2Q8z5KiseOlvKA/RF2wqU0UPYqQviQhLmW6THTpmrv/YkUCuzxDpsH7DUDhZcwySLKVVe0Qm3+5N2Ta6UYH3lsDf9R9wTP2K/+vAnflKebuypNlmocIvakFWoZda18FOmsOoIVXQ8HWFNCuw9ZCunMSN62QGamCe3dL5cXlkgHYv7ekJE15IA9aOJcM7e90oeTqo+7HTcWfdu0qQqPWY5ujyMw/llas8tsXY85LFqRnr3gJ02bAscjc477+X+j/gkpFoN1QEmt terraform@demo.tld"
    }
  }

  agent_pool_profile {
    name            = "default"
    count           = "${var.agent_count}"
    vm_size         = "Standard_A1"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags {
    Environment = "Production"
  }
}

provider "kubernetes" {
  host = "${azurerm_kubernetes_cluster.main.kube_config.0.host}"

  #username               = "${azurerm_kubernetes_cluster.main.kube_config.0.username}"
  #password               = "${azurerm_kubernetes_cluster.main.kube_config.0.password}"
  client_certificate = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_certificate)}"

  client_key             = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.main.kube_config.0.cluster_ca_certificate)}"
}

resource "kubernetes_pod" "db" {
  metadata {
    name = "nodejs-micro-example-db"
  }

  spec {
    container {
      # todo version me
      image = "mongo"
      name  = "nodejs-micro-example-db"
    }
  }
}

resource "kubernetes_pod" "service" {
  metadata {
    name = "nodejs-micro-example-service"
  }

  spec {
    container {
      image = "${var.docker_registry_name}.azurecr.io/service:${var.version}"
      name  = "nodejs-micro-example-service"
    }
  }
}

resource "kubernetes_pod" "web" {
  metadata {
    # todo: does this matter?
    name = "nodejs-micro-example-web"

    labels {
      name = "nodejs-micro-example-web"
    }
  }

  spec {
    container {
      image = "${var.docker_registry_name}.azurecr.io/web:${var.version}"
      name  = "nodejs-micro-example-web"
    }
  }
}

resource "kubernetes_service" "web" {
  metadata {
    name = "web"
  }

  spec {
    selector {
      name = "${kubernetes_pod.web.metadata.0.labels.name}"
    }

    session_affinity = "ClientIP"

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
