provider "kubernetes" {
  version = "~> 1.2"
  host = "${google_container_cluster.primary.endpoint}"
  username = "${local.k8s_username}"
  password = "${local.k8s_passwd}"
  client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}


resource "kubernetes_service" "example" {
  metadata {
    name = "terraform-service-example"
  }
  spec {
    selector {
      app = "${kubernetes_pod.example.metadata.0.labels.app}"
    }
    session_affinity = "ClientIP"
    port {
      port = 8080
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

resource "kubernetes_pod" "example" {
  metadata {
    name = "terraform-pod-example"
    labels {
      app = "MyApp"
    }
  }

  spec {
    container {
      image = "nginx:1.7.9"
      name  = "example"
    }
  }
}

output "service_endpoint" {
  value = "${kubernetes_service.example.load_balancer_ingress}"
}
