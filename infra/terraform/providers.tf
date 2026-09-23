terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }

  # Backend local por enquanto. Em produção, mover o state para um
  # Storage Account (azurerm backend) — feito na fase de CI/CD.
  # backend "azurerm" {}
}

provider "azurerm" {
  features {}
  # subscription_id vem de ARM_SUBSCRIPTION_ID ou `az account set`.
  # Usar a assinatura "Azure for Students".
}

provider "random" {}
