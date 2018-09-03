provider "kubernetes" {
  version = "~> 1.2"
  host = "${google_container_cluster.primary.endpoint}"
  username = "${local.k8s_username}"
  password = "${local.k8s_passwd}"
  client_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.client_certificate)}"
  client_key = "${base64decode(google_container_cluster.primary.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)}"
}


//                 _
// _ __   ___  ___| |_ __ _ _ __ ___  ___
//| '_ \ / _ \/ __| __/ _` | '__/ _ \/ __|
//| |_) | (_) \__ \ || (_| | | |  __/\__ \
//| .__/ \___/|___/\__\__, |_|  \___||___/
//|_|                 |___/


locals {
  postgress_port = 5432
}

resource "random_string" "postgres_password" {
  length = 16
}

resource "kubernetes_service" "postgres" {
  metadata {
    name = "postgres"
    labels = {
      app = "postgres"
    }
  }

  spec {
    selector {
      app = "${kubernetes_pod.postgres.metadata.0.labels.app}"
    }
    type = "ClusterIP"
    port = {
      port = "${local.postgress_port}"
    }
  }
}

resource "kubernetes_pod" "postgres" {
  metadata {
    name = "postgres"
    labels {
      app = "postgres"
    }
  }
  spec {
    container {
      image = "livingdocs/postgres:9.6"
      name = "postgres"

      env {
        name = "POSTGRES_PASSWORD"
        value_from {
          secret_key_ref {
            name = "postgres"
            key = "password"
          }
        }
      }
      liveness_probe {
        exec {
          command = [
            "/bin/sh",
            "-i",
            "-c",
            "pg_isready -U postgres -h 127.0.0.1 -p ${local.postgress_port}"]

        }
        failure_threshold = 3
        initial_delay_seconds = 30
        period_seconds = 10
        success_threshold = 1
        timeout_seconds = 1
      }

      port {
        container_port = "${local.postgress_port}"
      }


      volume_mount {
        name = "postgres-persistent-storage"
        mount_path = "/var/lib/postgres"
      }
    }
    volume {
      name = "postgres-persistent-storage"
      gce_persistent_disk {
        pd_name = "${google_compute_disk.postgres.name}"
      }

    }
  }
}

resource "kubernetes_secret" "postgres" {
  metadata {
    name = "postgres"
  }
  data {
    password = "${random_string.postgres_password.result}"
  }
}

//      _           _   _                              _
//  ___| | __ _ ___| |_(_) ___ ___  ___  __ _ _ __ ___| |__
// / _ \ |/ _` / __| __| |/ __/ __|/ _ \/ _` | '__/ __| '_ \
//|  __/ | (_| \__ \ |_| | (__\__ \  __/ (_| | | | (__| | | |
//\___|_|\__,_|___/\__|_|\___|___/\___|\__,_|_|  \___|_| |_|
//

resource "kubernetes_service" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels = {
      app = "elasticsearch"
    }
  }

  spec {
    selector {
      app = "${kubernetes_pod.elasticsearch.metadata.0.labels.app}"
    }
    type = "ClusterIP"
    port = {
      port = 9200
    }
  }
}

resource "kubernetes_pod" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels {
      app = "elasticsearch"
    }
  }
  spec {
    container {
      image = "livingdocs/elasticsearch"
      name = "elasticsearch"
      port {
        container_port = 9200
        name = "rest"
      }
      port {
        container_port = 9300
        name = "transport"
      }
      liveness_probe {
        tcp_socket {
          port = "transport"
        }
        initial_delay_seconds = 20
        period_seconds = 10
      }
    }

  }
}

// _ _       _                 _
//| (_)_   _(_)_ __   __ _  __| | ___   ___ ___       ___  ___ _ ____   _____ _ __
//| | \ \ / / | '_ \ / _` |/ _` |/ _ \ / __/ __|_____/ __|/ _ \ '__\ \ / / _ \ '__|
//| | |\ V /| | | | | (_| | (_| | (_) | (__\__ \_____\__ \  __/ |   \ V /  __/ |
//|_|_| \_/ |_|_| |_|\__, |\__,_|\___/ \___|___/     |___/\___|_|    \_/ \___|_|
//|___/

resource "kubernetes_pod" "bluewin_server" {
  metadata {
    name = "bluewin-server"
    labels {
      app = "bluewin-server"
    }
  }
  spec {


    init_container {
      name = "database-setup"
      image = "gcr.io/kubernetes-test-214207/bluewin-server:db-config"
      command = ["/bin/sh", "-c", "-i"]
      //TODO: How to run migrations just once?
      args = ["grunt database-recreate && grunt migrate"]
      env {
        name = "db__host"
        value = "${kubernetes_service.postgres.metadata.0.name}"
      }
      env {
        name = "db__port"
        value = "${kubernetes_service.postgres.spec.0.port.0.port}"
      }
      env {
        name = "db__user"
        value = "postgres"
      }
      env {
        name = "db__password"
        value_from {
          secret_key_ref {
            name = "postgres"
            key = "password"
          }
        }
      }

      env {
        name = "PGPASSWORD"
        value_from {
          secret_key_ref {
            name = "postgres"
            key = "password"
          }
        }
      }

      env {
        name = "search__host"
        value = "http://${kubernetes_service.elasticsearch.metadata.0.name}:${kubernetes_service.elasticsearch.spec.0.port.0.port}"
      }
    }

    container {
      image = "gcr.io/kubernetes-test-214207/bluewin-server:db-config"
      name = "bluewin-server"
      env {
        name = "db__host"
        value = "${kubernetes_service.postgres.metadata.0.name}"
      }
      env {
        name = "db__port"
        value = "${kubernetes_service.postgres.spec.0.port.0.port}"
      }
      env {
        name = "db__user"
        value = "postgres"
      }
      env {
        name = "db__password"
        value_from {
          secret_key_ref {
            name = "postgres"
            key = "password"
          }
        }
      }
      env {
        name = "search__host"
        value = "http://${kubernetes_service.elasticsearch.metadata.0.name}:${kubernetes_service.elasticsearch.spec.0.port.0.port}"
      }
      port {
        container_port = 9090
        name = "http"
      }
      liveness_probe {
        http_get {
          port = "http"
          path = "/status"

        }
      }
    }
  }
}

resource "kubernetes_service" "bluewin-server" {
  metadata {
    name = "bluewin-server"
    labels = {
      app = "bluewin-server"
    }
  }
  spec {
    type = "ClusterIP"
    selector {
      app = "${kubernetes_pod.bluewin_server.metadata.0.labels.app}"
    }
    port = {
      port = 9090

    }
  }
}

resource "kubernetes_pod" "bluewin-editor" {
  "metadata" {
    name = "bluewin-editor"
    labels = {
      app = "bluewin-editor"
    }
  }
  "spec" {
    container {
      name = "bluewin-editor"
      image = "gcr.io/kubernetes-test-214207/bluewin-editor:permission-hack"
      env {
        name = "api__host"
        value = "http://bluewin-server:9090"
      }
    }
  }
}

resource "kubernetes_service" "bluewin-editor" {
  metadata {
    name = "bluewin-editor"
    labels = {
      app = "bluewin-editor"
    }
  }
  spec {
    type = "LoadBalancer"
    selector {
      app= "${kubernetes_pod.bluewin-editor.metadata.0.labels.app}"
    }
    port {
      port = 80
      target_port = "9000"
    }
  }
}