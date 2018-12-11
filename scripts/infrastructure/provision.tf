provider "azurerm" {}

resource "azurerm_resource_group" "k8s" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_storage_account" "docker_storage" {
  name                     = "${var.docker_registry_name}"
  resource_group_name      = "${azurerm_resource_group.k8s.name}"
  location                 = "${azurerm_resource_group.k8s.location}"
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_container_registry" "docker_registry" {
  name                = "nodejsmicroexample"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
  location            = "${azurerm_resource_group.k8s.location}"
  admin_enabled       = true
  sku                 = "Classic"
  storage_account_id  = "${azurerm_storage_account.docker_storage.id}"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "${var.cluster_name}"
  location            = "${azurerm_resource_group.k8s.location}"
  resource_group_name = "${azurerm_resource_group.k8s.name}"
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

# todo: Examples of other outputs.
# See video: https://channel9.msdn.com/Shows/Azure-Friday/Provisioning-Kubernetes-clusters-on-AKS-using-HashiCorp-Terraform?utm_source=newsletter&utm_medium=email&utm_campaign=Learn%20By%20Doing
# At time: 5:18
# Also can output some commands to configure kubectrl!
# 5:26

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config_raw}"
}

output "host" {
  value = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"
}

provider "kubernetes" {
  host = "${azurerm_kubernetes_cluster.k8s.kube_config.0.host}"

  #username               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.username}"
  #password               = "${azurerm_kubernetes_cluster.k8s.kube_config.0.password}"
  client_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_certificate)}"

  client_key             = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.k8s.kube_config.0.cluster_ca_certificate)}"
}

resource "null_resource" "build" {
  provisioner "local-exec" {
    command = "sudo -E docker-compose -f ../../docker-compose-prod.yml build"

    environment {
      DOCKER_REGISTRY = "${var.docker_registry_name}.azurecr.io"
    }
  }
}

resource "null_resource" "docker_login" {
  depends_on = [
    "azurerm_container_registry.docker_registry",
  ]

  provisioner "local-exec" {
    command = "sudo -E docker login $DOCKER_REGISTRY -u=${azurerm_container_registry.docker_registry.admin_username} -p=${azurerm_container_registry.docker_registry.admin_password}"

    environment {
      DOCKER_REGISTRY = "${var.docker_registry_name}.azurecr.io"
    }
  }
}

resource "null_resource" "push_service" {
  depends_on = [
    "null_resource.build",
    "null_resource.docker_login",
  ]

  provisioner "local-exec" {
    command = "sudo -E docker push $DOCKER_REGISTRY/service"

    environment {
      DOCKER_REGISTRY = "${var.docker_registry_name}.azurecr.io"
    }
  }
}

resource "null_resource" "push_web" {
  depends_on = [
    "null_resource.build",
    "null_resource.docker_login",
  ]

  provisioner "local-exec" {
    command = "sudo -E docker push $DOCKER_REGISTRY/web"

    environment {
      DOCKER_REGISTRY = "${var.docker_registry_name}.azurecr.io"
    }
  }
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
  depends_on = ["null_resource.push_service"]

  metadata {
    name = "nodejs-micro-example-service"
  }

  spec {
    container {
      image = "${var.docker_registry_name}.azurecr.io/service"
      name  = "nodejs-micro-example-service"
    }
  }
}

resource "kubernetes_pod" "web" {
  depends_on = ["null_resource.push_web"]

  metadata {
    # todo: does this matter?
    name = "nodejs-micro-example-web"

    labels {
      name = "nodejs-micro-example-web"
    }
  }

  spec {
    container {
      image = "${var.docker_registry_name}.azurecr.io/web"
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

output "loadbalancer_ip" {
  value = "${kubernetes_service.web.load_balancer_ingress.0.ip}"
}
