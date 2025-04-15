
# Port Forwarding for Monitoring Tools

# This script is used to set up port forwarding for monitoring tools like Grafana and Prometheus in a Kubernetes cluster.



chmod +x start-monitoring.sh
./start-monitoring.sh


chmod +x stop-monitoring.sh
./stop-monitoring.sh



pkill -f "kubectl port-forward -n monitoring svc/grafana"
pkill -f "kubectl port-forward -n monitoring svc/prometheus-server"
