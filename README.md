# Showcasing Livingdocs in Kubernetes Cluster

## Why

This is a showcase to demonstrate the capabilities of terraform and 
kubernetes in the context of a livingdocs system.

## How to run

### Prerequisites

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


```bash
gcloud auth application-default login
cd tf
terraform init
terraform apply
```

# How to 

## TODO

- [x] Spin up a kubernetes Cluster in Google Cloud
- [X] Deploy a very simple application and access it
- [X] Deploy an application with a database
- [X] Make it possible to use private docker images
- [ ] Provision the actual livingdocs system
  - [ ] Configuration for the individual server so they can talk to the database/editor/etc
  - [ ] Liveness and readiness probes
  - [ ] This could totally be documented afterwards but where?
  - [ ] What do we want to show in the presentation?
- [ ] Get Ivans take on PoC requirements
  
