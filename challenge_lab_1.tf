KodeKloud : Terraform challenge 1
----------------------


1. Terraform 1.1.5 binaries
wget https://releases.hashicorp.com/terraform/1.1.5/terraform_1.1.5_linux_amd64.zip

apt update

apt install unzip

unzip terraform_1.1.5_linux_amd64.zip
mv terraform /usr/local/bin

terraform version


2. Configure terraform provider to connect to local k8s

file : provider.tf
---------------

terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.11.0"
    }
  }
}

provider "kubernetes" {
  config_path    = "/root/.kube/config"
  config_context = "kubernetes-admin@kubernetes"
}


file : deployment.tf
--------------

resource "kubernetes_deployment" "frontend" {
  metadata {
    name = "frontend"
    labels = {
      name = "frontend"
    }
  }

  spec {
    replicas = 4

    selector {
      match_labels = {
        name = "webapp"
      }
    }

    template {
      metadata {
        labels = {
          name = "webapp"
        }
      }

      spec {
        container {
          image = "kodekloud/webapp-color:v1"
          name  = "simple-webapp" 
          port { container_port = 8080}
        }       
      }
    }
  }
}


file : service.tf
------------

resource "kubernetes_service" "webapp-service" {
  metadata {
    name = "webapp-service"
  }
  spec {
    selector = {
      name = frontend
    }
    port {
      port        = 8080
      NodePort = 30080
    }
*
    type = "NodePort"
  }
}

# Launch everything

terraform init && terraform plan && terraform apply -auto-approve
