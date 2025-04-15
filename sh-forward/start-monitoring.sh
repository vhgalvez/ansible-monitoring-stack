#!/bin/bash

echo "🔄 Iniciando port-forward para Grafana..."
nohup kubectl port-forward -n monitoring svc/grafana 3000:80 > grafana.log 2>&1 &

echo "🔄 Iniciando port-forward para Prometheus..."
nohup kubectl port-forward -n monitoring svc/prometheus-server 9090:80 > prometheus.log 2>&1 &

echo "✅ Port-forward en segundo plano. Verifica con: ps aux | grep port-forward"