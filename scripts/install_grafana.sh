#!/usr/bin/env bash
set -eo pipefail
source bash-functions.sh

cluster_name=$1
grafana_chart_version=$(jq -er .grafana_chart_version environments/$cluster_name.json)
echo "grafana chart version $grafana_chart_version"

# helm repo add grafana https://grafana.github.io/helm-charts
# helm repo update

# perform trivy scan of chart with install configuration
#trivyScan "grafana/grafana" "grafana" "$grafana_chart_version" "grafana-values/$cluster_name-values.yaml"

cat <<EOF > grafana-values/grafana-oauth-secrets.yaml
---
apiVersion: v1
kind: Secret
metadata:
  name: grafana-oauth-secrets
  namespace: observe
stringData:
  GF_AUTH_GITHUB_ENABLED: "true"
  GF_AUTH_GITHUB_CLIENT_ID: $GITHUB_OAUTH_APP_CLIENT_ID
  GF_AUTH_GITHUB_CLIENT_SECRET: $GITHUB_OAUTH_APP_CLIENT_SECRET
  GF_AUTH_GITHUB_ALLOWED_ORGANIZATIONS: "twplatformlabs"
  GF_AUTH_GITHUB_ORG_MAPPING:  "@twplatformlabs/platform:*:Admin"
  GF_AUTH_GITHUB_ALLOW_SIGN_UP: "true"
  GF_AUTH_GITHUB_SCOPES: "user:email,read:org"
  GF_AUTH_GITHUB_AUTH_URL: https://github.com/login/oauth/authorize
  GF_AUTH_GITHUB_TOKEN_URL: https://github.com/login/oauth/access_token
  GF_AUTH_GITHUB_API_URL: https://api.github.com/user
EOF

cat <<EOF > grafana-values/grafana-virtualservice.yaml
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: grafana
  namespace: observe
  labels:
    app: grafana
    env: observe
    helm.sh/chart: grafana-8.10.3
    app.kubernetes.io/name: grafana
    app.kubernetes.io/instance: grafana
spec:
  hosts:
    - grafana.sbx-i01-aws-us-east-1.twplatformlabs.org
  gateways:
    - istio-system/sbx-i01-aws-us-east-1-twplatformlabs-org-gateway
  http:
    - route:
      - destination:
          host: grafana.observe.svc.cluster.local
          port:
            number: 80
EOF

kubectl apply -f grafana-values/grafana-oauth-secrets.yaml
kubectl apply -f grafana-values/grafana-virtualservice.yaml

helm upgrade --install grafana grafana/grafana \
             --version $grafana_chart_version \
             --namespace observe \
             --values grafana-values/$cluster_name-values.yaml

# helm template grafana grafana/grafana \
#              --version 8.10.3 \
#              --namespace observe \
#              --values grafana-values/sbx-i01-aws-us-east-1-values.yaml