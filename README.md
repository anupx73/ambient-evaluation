# Introduction

This repository contains an evaluation of Ambient mesh on Kubernetes environment from performance and operation complexity perspective.

# Ambient Mesh
A service mesh architecture and part of open source project Istio. This eliminates sidecar proxy injection in service mesh. Visit [istio.io](https://istio.io/latest/blog/2022/introducing-ambient-mesh/), [solo.io](https://www.solo.io/blog/istio-ambient-mesh-evolution-service-mesh/) for more information.

# Cloud Infrastructure
GKE cluster is created using Terraform script. Istio sidecar and ambient mode is then installed with Istioctl tool downloaded on local system. Istio operator is used to upgrade Istio version using blue-green deployment model. A demo application called Bank of Anthos is used to test the Istio functionality and load generation. This application source code and k8s manifest files are available at [GoogleCloudPlatform](https://github.com/GoogleCloudPlatform/bank-of-anthos) repository.

# Folder Structure

    .
    ├── gke                        # Terraform IaC source
    ├── k8s-manifest               # Forked from BOA; YAML to deploy BOA microservices to a single namespace
    ├── k8s-manifest-multi-ns      # Forked and modified; YAML to deploy BOA microservices to multiple namespaces
    ├── loadgenerator              # Forked from BOA; docker run from localhost to simulate traffic
    ├── misc                       # Grafana dashboard JSON; Waypoint proxy policy
    ├── ops                        # Operational scripts
    ├── tex                        # LaTeX source of the thesis
    └── README.md

Grafana dashboard credit goes to [solo-io](https://github.com/solo-io/ambient-performance/tree/fortio-ambient).
