#!/usr/bin/env bash
set -eo pipefail

cluster_name=$1

# create observability demo namespace
echo "observability demo namespace"
kubectl apply -f tpl/observability-demo-namespace.yaml

# create prometheus efs-csi persistent volume claim
echo "create persistent volume claims for prometheus"
cat <<EOF > prometheus-values/pvc.yaml
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: prometheus-efs-pvc
  namespace: observe
spec:
  accessModes:
    - ReadWriteOnce
  storageClassName: ${cluster_name}-efs-csi-dynamic-storage
  resources:
    requests:
      storage: 8Gi
EOF
kubectl apply -f prometheus-values/pvc.yaml
