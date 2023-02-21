
variable "project_name" {
  type = string
  description = "Project name"
}

variable "storage_account_name" {
  type = string
  description = "Storage account name"
}

variable "function_app_name" {
  type = string
  description = "Function app name"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name = var.project_name
  location = "japaneast"

  tags = {
    environment = "dev"
  }
}

// https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/function_app
resource "azurerm_storage_account" "storage_account" {
  name = var.storage_account_name
  resource_group_name = azurerm_resource_group.resource_group.name
  location = azurerm_resource_group.resource_group.location
  account_tier = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "service_plan" {
  name = var.project_name
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_function_app" "az_func" {
  name = var.function_app_name
  location = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  app_service_plan_id = azurerm_app_service_plan.service_plan.id
  storage_account_name = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version = "~4"
  https_only = true
}
