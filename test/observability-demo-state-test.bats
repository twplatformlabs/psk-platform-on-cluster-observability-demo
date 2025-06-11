#!/usr/bin/env bats

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
