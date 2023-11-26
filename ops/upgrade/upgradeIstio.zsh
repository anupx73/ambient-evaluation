#!/bin/zsh
#
# Use source upgradeIstio.zsh to use the functions of this file
#

initUpgrade() {
  kubectl create namespace istio-operator
  kubectl create namespace istio-system
  kubectl create namespace istio-gateways
  kubectl create namespace istio-config

  # Set environment variables
  WORK_DIR=$HOME/anupx73/ambient-evaluation/ops/upgrade/
  ISTIO_19_VERSION=1.19.3
  ISTIO_19_REVISION=1-19-3
  ISTIO_19_DIR=$WORK_DIR/$ISTIO_19_REVISION
  ISTIO_20_VERSION=1.20.0
  ISTIO_20_REVISION=1-20-0
  ISTIO_20_DIR=$WORK_DIR/$ISTIO_20_REVISION
}

deployIstioOperator() {
  # in the 1-19-3 folder
  cd $ISTIO_19_DIR
  curl -L https://istio.io/downloadIstio | ISTIO_VERSION=$ISTIO_19_VERSION sh -

  # Deploy operator
  helm template istio-operator-$ISTIO_19_REVISION $ISTIO_19_DIR/istio-$ISTIO_19_VERSION/manifests/charts/istio-operator \
    --namespace istio-operator \
    --include-crds \
    --set operatorNamespace=istio-operator \
    --set watchedNamespaces="istio-system\,istio-gateways" \
    --set global.hub="docker.io/istio" \
    --set global.tag="$ISTIO_19_VERSION" \
    --set revision="$ISTIO_19_REVISION" > $ISTIO_19_DIR/operator.yaml

  # apply the operator
  kubectl apply -f $ISTIO_19_DIR/operator.yaml --namespace istio-operator

  # wait for operator to be ready
  sleep 20s
}

deployIstiod() {
  # install IstioOperator spec 
  # --> change this istioOptSpec.yaml
  kubectl apply -f $ISTIO_19_DIR/istiooperator.yaml
}

deployIstioIngressGateway() {
  # in the 1-19-3 folder
  cd $ISTIO_19_DIR

  # copy configmap from istio-system to istio-gateways
  CM_DATA=$(kubectl get configmap istio-$ISTIO_19_REVISION -n istio-system -o jsonpath={.data})
  cat > $ISTIO_19_DIR/istio-$ISTIO_19_REVISION.json << EOF
{
    "apiVersion": "v1",
    "data": $CM_DATA,
    "kind": "ConfigMap",
    "metadata": {
        "labels": {
            "istio.io/rev": "$ISTIO_19_REVISION"
        },
        "name": "istio-$ISTIO_19_REVISION",
        "namespace": "istio-gateways"
    }
}
EOF

  kubectl apply -f $ISTIO_19_DIR/istio-$ISTIO_19_REVISION.json
  kubectl apply -n istio-gateways -f $ISTIO_19_DIR/ingressgateway.yaml
}

deployK8sLB() {
  kubectl apply -f $WORK_DIR/k8s-lb-service.yaml
}

cleanup() {
  kubectl delete -n istio-gateways -f $ISTIO_19_DIR/ingressgateway.yaml
  kubectl delete -f $ISTIO_19_DIR/istio-$ISTIO_19_REVISION.json
  
  # --> change this istioOptSpec.yaml
  kubectl delete -f $ISTIO_19_DIR/istiooperator.yaml
  kubectl delete -f $ISTIO_19_DIR/operator.yaml --namespace istio-operator

  kubectl delete -f $WORK_DIR/k8s-lb-service.yaml
}
