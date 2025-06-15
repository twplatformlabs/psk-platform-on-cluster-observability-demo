#!/usr/bin/env bats

# Prometheus smoke tests
@test "prometheus-server status is Running" {
  run bash -c "kubectl get po -n observe -l app.kubernetes.io/name=prometheus -o wide | grep 'prometheus-server'"
  [[ "${output}" =~ "Running" ]]
}

@test "prometheus-alertmanager status is Running" {
  run bash -c "kubectl get po -n observe -l app.kubernetes.io/name=alertmanager -o wide | grep 'prometheus-alertmanager'"
  [[ "${output}" =~ "Running" ]]
}

@test "prometheus-node-exporter status is Running" {
  run bash -c "kubectl get po -n observe -o wide | grep 'prometheus-node-exporter'"
  [[ "${output}" =~ "Running" ]]
}

@test "prometheus-alertmanager oauth2-proxies status is Running" {
  run bash -c "kubectl get po -n observe -l app.kubernetes.io/name=prometheus-alertmanager-oauth2-proxy -o wide | grep 'prometheus-alertmanager-oauth2-proxy'"
  [[ "${output}" =~ "Running" ]]
}

@test "prometheus-server oauth2-proxies status is Running" {
  run bash -c "kubectl get po -n observe -l app.kubernetes.io/name=prometheus-server-oauth2-proxy -o wide | grep 'prometheus-server-oauth2-proxy'"
  [[ "${output}" =~ "Running" ]]
}

# Grafana smoke tests
@test "grafana status is Running" {
  run bash -c "kubectl get po -n observe -o wide | grep 'grafana'"
  [[ "${output}" =~ "Running" ]]
}

# otel collector smoke tests
@test "node otel-collector agent status is Running" {
  run bash -c "kubectl get po -n observe -l name=node-opentelemetry-collector -o wide | grep 'node-opentelemetry-collector'"
  [[ "${output}" =~ "Running" ]]
}

@test "cluster otel-collector agent status is Running" {
  run bash -c "kubectl get po -n observe -l name=cluster-opentelemetry-collector -o wide | grep 'cluster-opentelemetry-collector'"
  [[ "${output}" =~ "Running" ]]
}