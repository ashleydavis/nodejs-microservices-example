provider "azurerm" {
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "docker_storage" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "terraform_container" {
  name                  = "terraform"
  resource_group_name   = azurerm_resource_group.main.name
  storage_account_name  = azurerm_storage_account.docker_storage.name
  container_access_type = "private"
}

resource "azurerm_container_registry" "docker_registry" {
  name                = var.docker_registry_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  admin_enabled       = true
  sku                 = "Basic"
}

