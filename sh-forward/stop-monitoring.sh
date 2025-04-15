#!/bin/bash

echo "🛑 Deteniendo port-forward de Grafana..."
pkill -f "kubectl port-forward -n monitoring svc/grafana"

echo "🛑 Deteniendo port-forward de Prometheus..."
pkill -f "kubectl port-forward -n monitoring svc/prometheus-server"

echo "✅ Todos los procesos de port-forward han sido detenidos."