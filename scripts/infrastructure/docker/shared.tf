provider "azurerm" {}

resource "azurerm_resource_group" "k8s" {
  name     = "${var.resource_group_name}" //todo: rename this to main
  location = "${var.location}"
}
