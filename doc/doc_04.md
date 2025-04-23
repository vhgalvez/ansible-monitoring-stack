📦 Instalación manual del stack de monitoreo con Helm
Este procedimiento permite desplegar manualmente Prometheus y Grafana en el clúster Kubernetes usando Helm, sin Ansible.

🔧 Pre-requisitos
Tener instalado kubectl y conectado al clúster.

Tener instalado helm (v3+).

Contar con un StorageClass funcional, por ejemplo longhorn.

1️⃣ Añadir los repositorios Helm
bash
Copiar
Editar
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
2️⃣ Crear namespace monitoring (si no existe)
bash
Copiar
Editar
kubectl create namespace monitoring
3️⃣ Crear archivo de configuración values-prometheus.yaml
yaml
Copiar
Editar
# /tmp/values-prometheus.yaml
server:
  containerPort: 9091

  extraArgs:
    web.listen-address: ":9091"

  persistentVolume:
    enabled: true
    storageClass: longhorn
    accessModes:
      - ReadWriteOnce
    size: 8Gi

  service:
    type: ClusterIP
    port: 9091
    targetPort: 9091
4️⃣ Crear archivo de configuración values-grafana.yaml
yaml
Copiar
Editar
# /tmp/values-grafana.yaml
adminUser: admin
adminPassword: admin123

persistence:
  enabled: true
  storageClassName: longhorn
  accessModes:
    - ReadWriteOnce
  size: 5Gi

service:
  type: ClusterIP
  port: 3000
  targetPort: 3000
  name: http
5️⃣ Instalar Prometheus
bash
Copiar
Editar
helm install prometheus prometheus-community/prometheus \
  -f /tmp/values-prometheus.yaml \
  --namespace monitoring --create-namespace
6️⃣ Instalar Grafana
bash
Copiar
Editar
helm install grafana grafana/grafana \
  -f /tmp/values-grafana.yaml \
  --namespace monitoring --create-namespace
✅ Verificar instalación
bash
Copiar
Editar
kubectl get pods -n monitoring
kubectl get pvc -n monitoring
Deberías ver pods de prometheus-*, grafana-*, y PVCs en estado Bound.

🧪 Acceder a la interfaz
Grafana (desde tu PC):
bash
Copiar
Editar
export POD=$(kubectl get pods -n monitoring -l "app.kubernetes.io/name=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n monitoring $POD 3000:3000
Visita: http://localhost:3000
Usuario: admin
Contraseña: admin123

Prometheus (puerto 9091 configurado):
bash
Copiar
Editar
export POD=$(kubectl get pods -n monitoring -l "app.kubernetes.io/name=prometheus" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n monitoring $POD 9091:9091
Visita: http://localhost:9091