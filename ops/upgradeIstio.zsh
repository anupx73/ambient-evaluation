#!/bin/zsh
#
# Use source upgradeIstio.zsh to use the functions of this file
#

initUpgrade() {
  # Set environment variables
  if [[ $1 = "1.18.5" ]]
  then
    ISTIO_VERSION=1.18.5
    ISTIO_REVISION=1-18-5
  elif [[ $1 = "1.19.3" ]]
  then
    ISTIO_VERSION=1.19.3
    ISTIO_REVISION=1-19-3
  elif [[ $1 = "1.20.0" ]]
  then
    ISTIO_VERSION=1.20.0
    ISTIO_REVISION=1-20-0
  else
    echo "No valid Istio versions provided! Aborting.."
    return 0
  fi

  # Set up folders
  WORK_DIR=$HOME/anupx73/ambient-evaluation/ops/
  ISTIO_DIR=$WORK_DIR/upgrade/$ISTIO_REVISION
  INIT_COMPLETED=1

  # Create required ns
  kubectl create namespace istio-operator
  kubectl create namespace istio-system
  kubectl create namespace istio-gateways
  kubectl create namespace istio-config

  # Print
  echo "Current directory: $WORK_DIR"
  echo "Istio will install in: $ISTIO_DIR"
}

deployIstioOperator() {
  if [[ $INIT_COMPLETED -lt 1 ]]
  then
    echo "initUpgrade() is pending! Aborting.."
    return 0
  fi

  cd $ISTIO_DIR
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_VERSION sh -
  cd -

  # Build operator template
  helm template istio-operator-$ISTIO_REVISION $ISTIO_DIR/istio-$ISTIO_VERSION/manifests/charts/istio-operator \
    --namespace istio-operator \
    --include-crds \
    --set operatorNamespace=istio-operator \
    --set watchedNamespaces="istio-system\,istio-gateways" \
    --set global.hub="docker.io/istio" \
    --set global.tag="$ISTIO_VERSION" \
    --set revision="$ISTIO_REVISION" > $ISTIO_DIR/operator.yaml

  # Apply the template to deploy Istio operator
  kubectl apply -f $ISTIO_DIR/operator.yaml --namespace istio-operator

  sleep 20
}

deployIstiod() {
  if [[ $INIT_COMPLETED -lt 1 ]]
  then
    echo "initUpgrade() is pending! Aborting.."
    return 0
  fi

  # Deploy Istod via IstioOperator spec deployment
  kubectl apply -f $ISTIO_DIR/operator-spec.yaml
}

deployIstioIngressGateway() {
  if [[ $INIT_COMPLETED -lt 1 ]]
  then
    echo "initUpgrade() is pending! Aborting.."
    return 0
  fi
  
  # copy configmap from istio-system to istio-gateways
  CM_DATA=$(kubectl get configmap istio-$ISTIO_REVISION -n istio-system -o jsonpath={.data})
  cat > $ISTIO_DIR/istio-$ISTIO_REVISION.json << EOF
{
    "apiVersion": "v1",
    "data": $CM_DATA,
    "kind": "ConfigMap",
    "metadata": {
        "labels": {
            "istio.io/rev": "$ISTIO_REVISION"
        },
        "name": "istio-$ISTIO_REVISION",
        "namespace": "istio-gateways"
    }
}
EOF

  kubectl apply -f $ISTIO_DIR/istio-$ISTIO_REVISION.json
  kubectl apply -n istio-gateways -f $ISTIO_DIR/ingressgateway.yaml
}

deployLB() {
  kubectl apply -f $WORK_DIR/upgrade/k8s-lb-service.yaml
}

labelAppNsStableIstio(){
  kubectl create ns boa
  kubectl label --overwrite ns boa istio.io/rev=1-18-5
}

labelAppNsCanaryIstio(){
  kubectl label --overwrite ns boa istio.io/rev=1-19-3
}

cleanup() {
  # istio operator, istiod
  kubectl delete -f $ISTIO_DIR/operator-spec.yaml
  kubectl delete -f $ISTIO_DIR/operator.yaml --namespace istio-operator

  # istio gateways
  kubectl delete -n istio-gateways -f $ISTIO_DIR/ingressgateway.yaml
  kubectl delete -f $ISTIO_DIR/istio-$ISTIO_REVISION.json

  # external lb
  kubectl delete -f $WORK_DIR/upgrade/k8s-lb-service.yaml

  if [ $? -ne 0 ]; then
    return 0
  fi

  # namespaces
  kubectl delete namespace istio-config
  kubectl delete namespace istio-gateways
  kubectl delete namespace istio-system
  kubectl delete namespace istio-operator
}

restartApps() {
  kubectl rollout restart deployment -n boa
}
