provider "google" {
  project = "kubernetes-test-214207"
  region = "us-central1"
  zone = "us-central1-a"
  version = "~> 1.17"
}

provider "random" {
  version = "~> 2.0"
}

resource "google_compute_disk" "mysql" {
  name = "mysql-disk"
  #gcloud compute disk-types list
  type = "pd-standard"
  zone = "us-central1-a"
  size = 10
}

resource "google_compute_disk" "wordpress" {
  name = "wordpress-disk"
  #gcloud compute disk-types list
  type = "pd-standard"
  zone = "us-central1-a"
  size = 10
}

locals {
  k8s_passwd = "${random_string.password.result}"
  k8s_username = "k8s-admin"
}

resource "google_container_cluster" "primary" {
  name = "livingdocs"

  initial_node_count = 1

  master_auth {
    username = "${local.k8s_username}"
    password = "${local.k8s_passwd}"
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