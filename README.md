# Ambient Mesh Evaluation

This is part of a M.Sc. Research project to evaluate Ambient mesh performance and operation complexity on Kubernetes environment. Ambient mesh is a state-of-the-art open source technology to eliminate sidecar proxy injection in service mesh. Visit [istio.io](https://istio.io/latest/blog/2022/introducing-ambient-mesh/), [solo.io](https://www.solo.io/blog/istio-ambient-mesh-evolution-service-mesh/) for more information.

## Bank of Anthos 
A sample application called Bank of Anthos (BOA) is used in this research as a HTTP-based web application. BOA simulates a virtual bank payment processing network, allowing users to create accounts and process transactions. This project is hosted officially at [GoogleCloudPlatform](https://github.com/GoogleCloudPlatform/bank-of-anthos) repository.

## Folder Structure

    .
    ├── gke                        # Terraform IaC source
    ├── k8s-manifest               # Forked from BOA; YAML to deploy BOA microservices to a single namespace
    ├── k8s-manifest-multi-ns      # Forked and modified; YAML to deploy BOA microservices to multiple namespaces
    ├── loadgenerator              # Forked from BOA; docker run from localhost to simulate traffic
    ├── misc                       # Grafana dashboard JSON; Waypoint proxy policy
    ├── ops                        # Operational scripts
    ├── tex                        # LateX source of the thesis
    └── README.md

Grafana dashboard credit goes to [solo-io](https://github.com/solo-io/ambient-performance/tree/fortio-ambient).
