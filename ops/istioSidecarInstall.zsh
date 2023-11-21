#!/bin/zsh
#
# Use source istioSidecarInstall.zsh to use the functions of this file
#

istioInstall() {
  # "Connecting to Cluster.."
  gcloud container clusters get-credentials tud-eu-west1-cluster --zone=europe-west1-b --project=tudublin

  # "Installing Istio in Sidecar Mode"
  istioctl install --set profile=default -y

  kubectl -n istio-system get service istio-ingressgateway
}

istioUninstall() {
  istioctl uninstall -y --purge
  kubectl delete ns istio-system
}

istioLabelSingleNS() {
  kubectl create ns boa
  kubectl label namespace boa istio-injection=enabled
}

istioLabelMultiNS() {
  kubectl create ns boa-ledger-db-ns
  kubectl create ns boa-acc-db-ns
  kubectl create ns boa-user-ns
  kubectl create ns boa-transaction-ns
  kubectl create ns boa-ledger-ns
  kubectl create ns boa-front-ns
  kubectl create ns boa-contact-ns
  kubectl create ns boa-balance-ns

  kubectl label namespace boa-acc-db-ns istio-injection=enabled
  kubectl label namespace boa-ledger-db-ns istio-injection=enabled
  kubectl label namespace boa-user-ns istio-injection=enabled
  kubectl label namespace boa-transaction-ns istio-injection=enabled
  kubectl label namespace boa-ledger-ns istio-injection=enabled
  kubectl label namespace boa-front-ns istio-injection=enabled
  kubectl label namespace boa-contact-ns istio-injection=enabled
  kubectl label namespace boa-balance-ns istio-injection=enabled
}
