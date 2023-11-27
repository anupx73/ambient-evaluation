#!/bin/zsh
#
# Use source upgradeIstio.zsh to use the functions of this file
# Functions in this script only works when called in a chain
#
# ###########################################################################################
# Istio upgrade in action
# ###########################################################################################
# >source upgradeIstio.zsh
# >initUpgrade 1.18.5
# >deployIstioOperator
# >deployIstiod
# >deployIstioIngressGateway          --> Istio 1.18.5 is live
#
# >deployLB                           --> can be called in any order; no dependency here
#
# >source appInstall.zsh
# >appCreateNs
# >labelAppNsStableIstio
# >appDeploy                          --> at this point BOA is part of Istio 1.18.5 and live
#
# >initUpgrade 1.19.3
# >deployIstioOperator
# >deployIstiod
# >deployIstioIngressGateway          --> Istio 1.19.3 is live
#
# >labelAppNsCanaryIstio              --> BOA is switched to Istio 1.19.3 but not live
# >sed -i'.bak' 's/1-18-5/1-19-3/' \
# ./upgrade/k8s-lb-service.yaml       --> Switching LB to point to Istio 1.19.3 ingress gateway
# 
# >restartApps                        --> Once BOA pods are restarted its part of Istio 1.19.3
#
# ############################################################################################
# Verification output
# ############################################################################################
# ❯ kubectl get all -n istio-operator
#      NAME                                         READY   STATUS    RESTARTS   AGE
#      pod/istio-operator-1-18-5-68b66bc5cc-h7wvd   1/1     Running   0          9m23s
#      pod/istio-operator-1-19-3-8586b4557f-j795m   1/1     Running   0          64s
#
#      NAME                            TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)    AGE
#      service/istio-operator-1-18-5   ClusterIP   10.30.76.68    <none>        8383/TCP   9m24s
#      service/istio-operator-1-19-3   ClusterIP   10.30.84.100   <none>        8383/TCP   64s
#
#      NAME                                    READY   UP-TO-DATE   AVAILABLE   AGE
#      deployment.apps/istio-operator-1-18-5   1/1     1            1           9m24s
#      deployment.apps/istio-operator-1-19-3   1/1     1            1           64s
#
#      NAME                                               DESIRED   CURRENT   READY   AGE
#      replicaset.apps/istio-operator-1-18-5-68b66bc5cc   1         1         1       9m24s
#      replicaset.apps/istio-operator-1-19-3-8586b4557f   1         1         1       64s
#
#
# ❯ kubectl get all -n istio-system
#      NAME                                 READY   STATUS    RESTARTS   AGE
#      pod/istiod-1-18-5-897bf57c-sb79m     1/1     Running   0          10m
#      pod/istiod-1-19-3-6c7f8bdfbd-4ds9z   1/1     Running   0          13s
#
#      NAME                    TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)                                 AGE
#      service/istiod-1-18-5   ClusterIP   10.30.156.232   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   10m
#      service/istiod-1-19-3   ClusterIP   10.30.101.166   <none>        15010/TCP,15012/TCP,443/TCP,15014/TCP   14s
#
#      NAME                            READY   UP-TO-DATE   AVAILABLE   AGE
#      deployment.apps/istiod-1-18-5   1/1     1            1           10m
#      deployment.apps/istiod-1-19-3   1/1     1            1           15s
#
#      NAME                                       DESIRED   CURRENT   READY   AGE
#      replicaset.apps/istiod-1-18-5-897bf57c     1         1         1       10m
#      replicaset.apps/istiod-1-19-3-6c7f8bdfbd   1         1         1       15s
#
#
# ❯ kubectl get all -n istio-gateways
#      NAME                                               READY   STATUS    RESTARTS   AGE
#      pod/istio-ingressgateway-1-18-5-76b8ffb7df-xw6fs   1/1     Running   0          11m
#      pod/istio-ingressgateway-1-19-3-67ccf5cd87-f8q2w   1/1     Running   0          14s
#
#      NAME                                  TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                                      AGE
#      service/istio-ingressgateway          LoadBalancer   10.30.161.116   35.233.110.2   15021:31155/TCP,80:30152/TCP,443:30841/TCP,31400:31590/TCP,15443:32579/TCP   10m
#      service/istio-ingressgateway-1-18-5   ClusterIP      10.30.158.170   <none>         15021/TCP,80/TCP,443/TCP,31400/TCP,15443/TCP                                 11m
#      service/istio-ingressgateway-1-19-3   ClusterIP      10.30.72.79     <none>         15021/TCP,80/TCP,443/TCP,31400/TCP,15443/TCP                                 15s
#
#      NAME                                          READY   UP-TO-DATE   AVAILABLE   AGE
#      deployment.apps/istio-ingressgateway-1-18-5   1/1     1            1           11m
#      deployment.apps/istio-ingressgateway-1-19-3   1/1     1            1           15s
#
#      NAME                                                     DESIRED   CURRENT   READY   AGE
#      replicaset.apps/istio-ingressgateway-1-18-5-76b8ffb7df   1         1         1       11m
#      replicaset.apps/istio-ingressgateway-1-19-3-67ccf5cd87   1         1         1       15s
#
#
# ❯ kubectl get svc -n istio-gateways -o wide
#      NAME                          TYPE           CLUSTER-IP      EXTERNAL-IP    PORT(S)                                                                      AGE     SELECTOR
#      istio-ingressgateway          LoadBalancer   10.30.161.116   35.233.110.2   15021:31155/TCP,80:30152/TCP,443:30841/TCP,31400:31590/TCP,15443:32579/TCP   13m     istio=ingressgateway,version=1-18-5
#      istio-ingressgateway-1-18-5   ClusterIP      10.30.158.170   <none>         15021/TCP,80/TCP,443/TCP,31400/TCP,15443/TCP                                 14m     app=istio-ingressgateway,istio=ingressgateway,version=1-18-5
#      istio-ingressgateway-1-19-3   ClusterIP      10.30.72.79     <none>         15021/TCP,80/TCP,443/TCP,31400/TCP,15443/TCP                                 3m15s   app=istio-ingressgateway,istio=ingressgateway,version=1-19-3
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
  WORK_DIR=$HOME/anupx73/ambient-evaluation/ops
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

  sleep 30
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
  kubectl label --overwrite ns boa istio.io/rev=1-18-5
}

labelAppNsCanaryIstio(){
  kubectl label --overwrite ns boa istio.io/rev=1-19-3
}

# this method stucked multiple times in action
# review later to fix the order of deletion
# a call to appDelete is possibly needed first
cleanup() {
  if [[ $INIT_COMPLETED -lt 1 ]]
  then
    echo "initUpgrade() is pending! Aborting.."
    return 0
  fi

  # external lb
  kubectl delete -f $WORK_DIR/upgrade/k8s-lb-service.yaml

  # istio gateways
  kubectl delete -f $ISTIO_DIR/ingressgateway.yaml -n istio-gateways
  kubectl delete -f $ISTIO_DIR/istio-$ISTIO_REVISION.json

  # istio operator, istiod
  kubectl delete -f $ISTIO_DIR/operator-spec.yaml
  kubectl delete -f $ISTIO_DIR/operator.yaml --namespace istio-operator

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
