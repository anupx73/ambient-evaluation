#!/bin/zsh
#
# Use source istioAmbientInstall.zsh to use the functions of this file
#

ambientInstall () {
  # "Connecting to Cluster.."
  gcloud container clusters get-credentials tud-eu-west1-cluster --zone=europe-west1-b --project=tudublin

  # Installing Istio in Ambient Mode
  istioctl install --set profile=ambient \
  --set "components.ingressGateways[0].enabled=true" \
  --set "components.ingressGateways[0].name=istio-ingressgateway" -y

  kubectl -n istio-system get service istio-ingressgateway
}

ambientL7Install() {
  # Installing K8s Gateway API CRD
  # kubectl get crd gateways.gateway.networking.k8s.io &> /dev/null || \
  #   { kubectl kustomize "github.com/kubernetes-sigs/gateway-api/config/crd?ref=v0.8.0" | kubectl apply -f -; }
  kubectl -n istio-system apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

  # Installing Istio Waypoint Proxy
  istioctl x waypoint apply -n boa
}

ambientL7InstallMultiNS() {
  kubectl -n istio-system apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml

  # Installing Istio Waypoint Proxy
  istioctl x waypoint apply -n boa-ledger-db-ns
  istioctl x waypoint apply -n boa-acc-db-ns
  istioctl x waypoint apply -n boa-user-ns
  istioctl x waypoint apply -n boa-transaction-ns
  istioctl x waypoint apply -n boa-ledger-ns
  istioctl x waypoint apply -n boa-front-ns
  istioctl x waypoint apply -n boa-contact-ns
  istioctl x waypoint apply -n boa-balance-ns
}

ambientL7UninstallMultiNS() {
  istioctl x waypoint delete -n boa-ledger-db-ns
  istioctl x waypoint delete -n boa-acc-db-ns
  istioctl x waypoint delete -n boa-user-ns
  istioctl x waypoint delete -n boa-transaction-ns
  istioctl x waypoint delete -n boa-ledger-ns
  istioctl x waypoint delete -n boa-front-ns
  istioctl x waypoint delete -n boa-contact-ns
  istioctl x waypoint delete -n boa-balance-ns

  kubectl -n istio-system delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml 
}

ambientUninstall() {
  istioctl uninstall -y --purge
  kubectl -n istio-system delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.0.0/standard-install.yaml 
  kubectl delete ns istio-system
}

ambientLabelSingleNS() {
  kubectl create ns boa
  kubectl label namespace boa istio.io/dataplane-mode=ambient
}

ambientLabelMultiNS() {
  kubectl create ns boa-ledger-db-ns
  kubectl create ns boa-acc-db-ns
  kubectl create ns boa-user-ns
  kubectl create ns boa-transaction-ns
  kubectl create ns boa-ledger-ns
  kubectl create ns boa-front-ns
  kubectl create ns boa-contact-ns
  kubectl create ns boa-balance-ns

  kubectl label namespace boa-acc-db-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-ledger-db-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-user-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-transaction-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-ledger-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-front-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-contact-ns istio.io/dataplane-mode=ambient
  kubectl label namespace boa-balance-ns istio.io/dataplane-mode=ambient
}
