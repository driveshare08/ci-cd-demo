###############################
# Resource Group
###############################
resource "azurerm_resource_group" "rg" {
  name     = "ci-cd-demo-rg"
  location = "ukwest"
}

###############################
# Azure Container Registry
###############################
resource "azurerm_container_registry" "acr" {
  name                = "cicddemoacr"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

###############################
# AKS Cluster
###############################
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "ci-cd-demo-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "ci-cd-demo-aks"

  default_node_pool {
    name       = "nodepool1"
    node_count = 1
    vm_size    = "Standard_D2s_v6"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  network_profile {
    network_plugin = "azure"
  }
}

###############################
# Allow AKS to Pull from ACR
###############################
resource "azurerm_role_assignment" "aks_acr" {
  principal_id         = azurerm_kubernetes_cluster.aks.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}
