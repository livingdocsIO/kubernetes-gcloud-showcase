# Showcasing Livingdocs in Kubernetes Cluster

## Why

This is a showcase to demonstrate the capabilities of terraform and 
kubernetes in the context of a livingdocs system.

## Getting started

### Prerequisites

TODO: Add instructions about copying private containers

#### Installation

- [terraform](https://www.terraform.io/downloads.html)
- [gcloud](https://cloud.google.com/sdk/gcloud/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

#### Accounts

A Google Cloud account is necessary. The free tier should be more than enough to test this showcase thoroughly.

### Initial setup

One needs a _project_ in Google Cloud to do anything.
This can be achieved by running `gcloud projects create my-special-project`.
In order to use this project per default from then on run `gcloud config set project my-special-project`.

### Running the showcase

Spin up the cluster with:

```bash
gcloud auth application-default login
cd tf
terraform init
terraform apply
```

The `kubectl` tool can be authenticated with a simple `gcloud container clusters get-credentials livingdocs`.

Now `kubectl` can be used to interact with the cluster. E. g.:
- `kubectl get namespaces` to show the namespaces in the cluster
- `kubectl --namespace livingdocs-develop get pods` to show all the pods in the showcase
- `kubectl --namespace livingdocs-develop exec -it my-special-pod -- /bin/bash` for a shell on my-special-pod. 



All the resources will be destroyed with a simple `terraform destroy`.

## TODOs

- [x] Spin up a kubernetes Cluster in Google Cloud
- [X] Deploy a very simple application and access it
- [X] Deploy an application with a database
- [X] Make it possible to use private docker images
- [X] Provision the actual livingdocs system
  - [X] Configuration for the individual server so they can talk to the database/editor/etc
  - [X] Liveness and readiness probes
  - [X] Use of replicasets
  - [ ] Ask how to generate users to show a login and interaction with the system
- [X] Introduce network policies
- [ ] Create a deployment + rollback
- [ ] Some prometheus monitoring

- [X] Get Ivans take on PoC requirements

## Presentation ideas

- Self healing
- Autoscaling
- Utilization
  
