#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
prometheus_chart_version=$(jq -er .prometheus_chart_version environments/$cluster_name.json)
echo "prometheus version $prometheus_chart_version"

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# perform trivy scan of chart with install configuration
trivyScan "prometheus-community/prometheus" "prometheus" "$prometheus_chart_version" "prometheus-values/$cluster_name-values.yaml"

helm upgrade --install prometheus prometheus-community/prometheus \
             --version $prometheus_chart_version \
             --namespace observe \
             --values prometheus-values/$cluster_name-values.yaml

sleep 30

# deploy oauth2 authentication proxy for alertmanager
helm upgrade --install prometheus-alertmanager-oauth2-proxy chart/oauth2-proxy \
     --namespace observe \
     --set env.OAUTH2_PROXY_CLIENT_ID="${OAUTH2_PROXY_CLIENT_ID}" \
     --set env.OAUTH2_PROXY_CLIENT_SECRET="${OAUTH2_PROXY_CLIENT_SECRET}" \
     --set env.OAUTH2_PROXY_COOKIE_SECRET="${OAUTH2_PROXY_COOKIE_SECRET}" \
     --values chart/oauth2-proxy/values.yaml \
     --values prometheus-values/$cluster_name-alertmanager-oauth2-proxy-values.yaml \

# deploy oauth2 authentication proxy for prometheus server
helm upgrade --install prometheus-server-oauth2-proxy chart/oauth2-proxy \
     --namespace observe \
     --set env.OAUTH2_PROXY_CLIENT_ID="${OAUTH2_PROXY_CLIENT_ID}" \
     --set env.OAUTH2_PROXY_CLIENT_SECRET="${OAUTH2_PROXY_CLIENT_SECRET}" \
     --set env.OAUTH2_PROXY_COOKIE_SECRET="${OAUTH2_PROXY_COOKIE_SECRET}" \
     --values chart/oauth2-proxy/values.yaml \
     --values prometheus-values/sbx-i01-aws-us-east-1-prometheus-oauth2-proxy-values.yaml \
