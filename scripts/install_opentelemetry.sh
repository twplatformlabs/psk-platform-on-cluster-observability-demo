#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
opentelemetry_collector_chart_version=$(jq -er .opentelemetry_collector_chart_version environments/$cluster_name.json)
echo "opentelemetry-collector chart version $opentelemetry_collector_chart_version"

# deploy honeycomb api-key
kubectl create secret generic honeycomb --from-literal=api-key=$HONEYCOMB_API_KEY --namespace=observe
sleep 10

helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# perform trivy scan of chart with install configuration
echo "trivyscan cluster-collector deployment"
trivyScan "open-telemetry/opentelemetry-collector" "opentelemetry-collector" "$opentelemetry_collector_chart_version" "opentelemetry-values/$cluster_name-opentelemetry-cluster-collector-values.yaml"
echo "trivy scan daemonset deployment"
trivyScan "open-telemetry/opentelemetry-collector" "opentelemetry-collector" "$opentelemetry_collector_chart_version" "opentelemetry-values/$cluster_name-opentelemetry-daemonset-collector-values.yaml"

# deploy otel cluster events collector
helm upgrade --install cluster open-telemetry/opentelemetry-collector \
     --namespace observe \
     --values opentelemetry-values/$cluster_name-opentelemetry-cluster-collector-values.yaml

# # deploy otel daemonset general collector
helm upgrade --install node open-telemetry/opentelemetry-collector \
     --namespace observe \
     --values opentelemetry-values/$cluster_name-opentelemetry-daemonset-collector-values.yaml
