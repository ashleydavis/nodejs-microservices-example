variable "version" {}

variable "agent_count" {
  default = 1
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "nodejs-micro-example"
}

variable cluster_name {
  default = "nodejs-micro-example"
}

variable resource_group_name {
  default = "nodejs-micro-example"
}

variable location {
  default = "Central US"
}

variable docker_registry_name {
  default = "nodejsmicroexample"
}
