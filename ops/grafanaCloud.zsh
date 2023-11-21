#!/bin/zsh
#
# Used for Grafana Cloud setup - Kept for reference purpose only
#

# Promtail log scraping setup with API key
curl -fsS https://raw.githubusercontent.com/grafana/loki/master/tools/promtail.sh | sh -s USER APIKEY logs-prod-eu-west-0.grafana.net boa | kubectl apply --namespace=boa -f  -

# Prometheus metrics scraping setup with Access policy token
helm install prometheus prometheus-community/prometheus -n monitoring
cat <<'EOF' |

server:
  remoteWrite:
  - url: https://prometheus-prod-24-prod-eu-west-2.grafana.net/api/prom/push
    basic_auth:
      username: USER
      password: PWD
    write_relabel_configs:
      - source_labels: ["__name__"]
        regex: "container_cpu_usage_seconds_total|container_memory_working_set_bytes"
        action: keep

EOF
(helm upgrade prometheus prometheus-community/prometheus -n monitoring -f -)