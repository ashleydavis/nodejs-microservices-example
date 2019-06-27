variable "buildno" {
}

variable "environment" {
}

variable "admin_username" {
  default = "linux_admin"
}

variable "agent_count" {
  default = 1
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
  default = "example"
}

variable "cluster_name" {
  default = "example"
}

variable "resource_group_name" {
  default = "ms-example-cluster"
}

variable "location" {
  default = "Central US"
}

variable "docker_registry_name" {
  default = "msexampletest"
}

