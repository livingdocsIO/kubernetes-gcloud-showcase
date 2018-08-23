provider "google" {
  project = "kubernetes-test-214207"
  region = "us-central1"
  zone = "us-central1-a"
  version = "~> 1.17"
}

provider "random" {
  version = "~> 2.0"
}

resource "google_compute_disk" "postgres" {
  name = "postgres-disk"
  #gcloud compute disk-types list
  type = "pd-standard"
  zone = "us-central1-a"
  size = 10
}

resource "google_container_cluster" "primary" {
  name = "livingdocs"

  initial_node_count = 3

  master_auth {
    username = "k8s-admin"
    password = "${random_string.password.result}"
  }

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
    labels {
      foo = "bar"
    }

    tags = ["foo", "bar"]
  }

}

resource "random_string" "password" {
  length = 16
}


# The following outputs allow authentication and connectivity to the GKE Cluster.
output "client_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.client_certificate}"
}

output "client_key" {
  value = "${google_container_cluster.primary.master_auth.0.client_key}"
}

output "cluster_ca_certificate" {
  value = "${google_container_cluster.primary.master_auth.0.cluster_ca_certificate}"
}

output "password" {
  value = "${random_string.password.result}"
}

