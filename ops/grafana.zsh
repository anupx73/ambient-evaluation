#!/bin/zsh
#
# Use source grafana.zsh to use the functions of this file
# 

grafanaInit () {
  helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
  helm repo update
}

grafanaInstall () {
  helm install prom-stack prometheus-community/kube-prometheus-stack -n monitoring --create-namespace
}

grafanaPortForward() {
  # Start Local Browser
  open -a Microsoft\ Edge "http://localhost:3000"

  # Port Forward
  grafanaPodName=$(kubectl --namespace monitoring get pod -l "app.kubernetes.io/name=grafana" --output jsonpath='{.items[0].metadata.name}')
  kubectl -n monitoring port-forward $grafanaPodName 3000:3000
}

grafanaUninstall () {
  helm uninstall prom-stack -n monitoring
  kubectl delete ns monitoring
}
