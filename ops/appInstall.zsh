#!/bin/zsh
#
# Use source appInstall.zsh to use the functions of this file
#

appDeploy() {
  kubectl create namespace boa
  kubectl apply -f $HOME/anupx73/ambient-evaluation/k8s-manifest -n boa
}

appScale() {
  kubectl scale --replicas=$1 deployment/balancereader -n boa &&
  kubectl scale --replicas=$1 deployment/contacts -n boa &&
  kubectl scale --replicas=$1 deployment/frontend -n boa &&
  kubectl scale --replicas=$1 deployment/ledgerwriter -n boa &&
  kubectl scale --replicas=$1 deployment/transactionhistory -n boa &&
  kubectl scale --replicas=$1 deployment/userservice -n boa
}

appDelete() {
  kubectl delete -f $HOME/anupx73/ambient-evaluation/k8s-manifest -n boa
  kubectl delete ns boa
}

labelBOAIstioRev19(){
  kubectl create namespace boa
  kubectl label ns boa istio.io/rev=$ISTIO_19_REVISION
}
