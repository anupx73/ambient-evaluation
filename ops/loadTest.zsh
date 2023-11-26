#!/bin/zsh
#
# Use source loadTest.zsh to use the functions of this file
#

startDocker() {
  open -a Docker
  sleep 20
}

buildLoadTestImg() {
  cd loadgenerator/
  docker build -t cd loadgen .
}

execLoadTest() {
  APP_ADDR=$(kubectl -n istio-system get service istio-ingressgateway --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
  docker run -e FRONTEND_ADDR=$APP_ADDR -it loadgen
}

execUpgradeLoadTest() {
  APP_ADDR=$(kubectl -n istio-gateways get service istio-ingressgateway --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
  docker run -e FRONTEND_ADDR=$APP_ADDR -it loadgen
}
