provider "kubernetes" {
  version = "~> 1.2"
  host = "${google_container_cluster.primary.endpoint}"
  username = "${local.k8s_username}"
  password = "${local.k8s_passwd}"
  client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}


resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }

  spec {
    selector {
      app = "${kubernetes_pod.mysql.metadata.0.labels.app}"
    }
    type = "ClusterIP"
    port =  {
      port = 3306
    }
  }
}

resource "kubernetes_pod" "mysql" {
  metadata {
    name = "mysql"
    labels {
      app = "mysql"
    }
  }
  spec {
    container {
      image = "mysql:5.6"
      name = "mysql"

      env {
        name = "MYSQL_ROOT_PASSWORD"
        value_from {
          secret_key_ref {
            name = "mysql"
            key = "password"
          }
        }
      }
      port {
        container_port = 3306
        name = "mysql"
      }

      volume_mount {
        name = "mysql-persistent-storage"
        mount_path = "/var/lib/mysql"
      }
    }
    volume {
      name = "mysql-persistent-storage"
      gce_persistent_disk {
        pd_name = "${google_compute_disk.mysql.name}"
      }

    }
  }
}

resource "kubernetes_secret" "mysql" {
  metadata {
    name = "mysql"
  }
  data {
    password = "P4ssw0rd"
  }
}

resource "kubernetes_pod" "wordpress" {
  metadata {
    name = "wordpress"
    labels {
      app = "wordpress"
    }
  }
  spec {
    container {
      image = "wordpress"
      name = "wordpress"
      env {
        name = "WORDPRESS_DB_HOST"
        value = "mysql:3306"
      }
      env {
        name = "WORDPRESS_DB_PASSWORD"
        value_from {
          secret_key_ref {
            name = "mysql"
            key = "password"
          }
        }
      }
      port {
        container_port = 80
        name = "wordpress"
      }

      volume_mount {
        name = "wordpress-persistent-storage"
        mount_path = "/var/www/html"
      }
    }
    volume {
      name = "wordpress-persistent-storage"
      gce_persistent_disk {
        pd_name = "${google_compute_disk.wordpress.name}"
      }
    }
  }
}
resource "kubernetes_service" "wordpress" {
  metadata {
    name = "wordpress"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    selector {
      app = "${kubernetes_pod.wordpress.metadata.0.labels.app}"
    }
    type = "LoadBalancer"
    selector {
      app = "${kubernetes_pod.wordpress.metadata.0.labels.app}"
    }
    port =  {
      port = 80
      target_port = 80
      protocol = "TCP"

    }
  }
}



