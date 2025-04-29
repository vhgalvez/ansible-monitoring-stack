# 📦 Instalación manual del stack de monitoreo con Helm

Este procedimiento permite desplegar manualmente **Prometheus** y **Grafana** en el clúster Kubernetes usando Helm, sin Ansible.

---

## 🔧 Pre-requisitos

- Tener instalado `kubectl` y conectado al clúster.
- Tener instalado `helm` (v3+).
- Contar con un `StorageClass` funcional, por ejemplo, **Longhorn**.

---

## 1️⃣ Añadir los repositorios Helm

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

---

## 2️⃣ Crear namespace `monitoring` (si no existe)

```bash
kubectl create namespace monitoring
```

---

## 3️⃣ Crear archivo de configuración para Prometheus

Archivo: `/tmp/values-prometheus.yaml`

```yaml
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
```

---

## 4️⃣ Crear archivo de configuración para Grafana

Archivo: `/tmp/values-grafana.yaml`

```yaml
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
```

---

## 5️⃣ Instalar Prometheus

```bash
helm install prometheus prometheus-community/prometheus \
  -f /tmp/values-prometheus.yaml \
  --namespace monitoring --create-namespace
```

---

## 6️⃣ Instalar Grafana

```bash
helm install grafana grafana/grafana \
  -f /tmp/values-grafana.yaml \
  --namespace monitoring --create-namespace
```

---

## ✅ Verificar instalación

```bash
kubectl get pods -n monitoring
kubectl get pvc -n monitoring
```

Deberías ver pods de `prometheus-*`, `grafana-*`, y PVCs en estado **Bound**.

---

## 🧪 Acceder a las interfaces

### Grafana (desde tu PC)

```bash
export POD=$(kubectl get pods -n monitoring -l "app.kubernetes.io/name=grafana" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n monitoring $POD 3000:3000
```

Visita: [http://localhost:3000](http://localhost:3000)  
Usuario: `admin`  
Contraseña: `admin123`

---

### Prometheus (puerto 9091 configurado)

```bash
export POD=$(kubectl get pods -n monitoring -l "app.kubernetes.io/name=prometheus" -o jsonpath="{.items[0].metadata.name}")
kubectl port-forward -n monitoring $POD 9091:9091
```

Visita: [http://localhost:9091](http://localhost:9091)

---

# 📘 Acceso Remoto al Clúster K3s desde Nodo de Administración

## 🎯 Objetivo

Permitir que el nodo de administración (`physical1`) se comunique con el API Server del clúster K3s utilizando `kubectl`, Ansible y módulos como `kubernetes.core.k8s`.

---

## 🖥️ Configuración en el Nodo de Administración (`physical1`)

### ✅ Paso 1: Obtener el archivo `k3s.yaml` desde `master1`

```bash
sudo scp -i /root/.ssh/cluster_k3s/shared/id_rsa_shared_cluster core@10.17.4.21:/etc/rancher/k3s/k3s.yaml /home/victory/k3s.yaml
```

---

### ✅ Paso 2: Crear la carpeta de configuración de `kubectl`

```bash
mkdir -p ~/.kube
```

---

### ✅ Paso 3: Copiar `k3s.yaml` como configuración por defecto

```bash
cp /home/victory/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

---

### ✅ Paso 4: Corregir la IP del servidor en `kubeconfig`

```bash
sudo sed -i 's/127.0.0.1/10.17.5.10/g' ~/.kube/config
```

---

### ✅ Paso 5: Verificar acceso al clúster

```bash
kubectl get nodes --insecure-skip-tls-verify
```

#### Resultado esperado:

```bash
NAME                            STATUS   ROLES                       AGE    VERSION
master1.cefaslocalserver.com    Ready    control-plane,etcd,master   4d7h   v1.32.3+k3s1
master2.cefaslocalserver.com    Ready    control-plane,etcd,master   4d7h   v1.32.3+k3s1
master3.cefaslocalserver.com    Ready    control-plane,etcd,master   4d7h   v1.32.3+k3s1
storage1.cefaslocalserver.com   Ready    <none>                      4d7h   v1.32.3+k3s1
worker1.cefaslocalserver.com    Ready    <none>                      4d7h   v1.32.3+k3s1
worker2.cefaslocalserver.com    Ready    <none>                      4d7h   v1.32.3+k3s1
worker3.cefaslocalserver.com    Ready    <none>                      4d7h   v1.32.3+k3s1
```

---

## 📌 Notas Adicionales

- El certificado del API Server es autofirmado, por lo que se requiere el flag `--insecure-skip-tls-verify` o configurar esta opción en el archivo `~/.kube/config`.
- Este proceso es esencial para que herramientas como Ansible, Helm y `kubectl` puedan interactuar con Kubernetes desde fuera del clúster.

---

## 🌐 Exportar configuración para Ansible

Para que Ansible reconozca la configuración de `kubectl`, exporta la variable de entorno:

```bash
export K8S_AUTH_KUBECONFIG=~/.kube/config
```

