#!/bin/bash

echo "🔄 Iniciando port-forward para Grafana..."

sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3001:80 > ~/grafana.log 2>&1 &

echo "🔄 Iniciando port-forward para Prometheus..."

sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:80 > ~/prometheus.log 2>&1 &

echo "✅ Port-forward en segundo plano. Verifica con: ps aux | grep port-forward"






