```markdown
# 🗑️ Eliminación de Recursos del Stack de Monitoreo

Este documento describe los pasos necesarios para eliminar los recursos relacionados con el stack de monitoreo (Grafana, Prometheus, PVCs, Pods, Servicios, etc.) en un clúster Kubernetes.

---

## 1️⃣ Eliminar Pods

Para eliminar todos los pods del namespace `monitoring`:

```bash
kubectl delete pods --all -n monitoring
```

---

## 2️⃣ Eliminar Deployments

Para eliminar todos los deployments en el namespace `monitoring`:

```bash
kubectl delete deployments --all -n monitoring
```

---

## 3️⃣ Eliminar StatefulSets

Para eliminar el StatefulSet de `prometheus-alertmanager`:

```bash
kubectl delete statefulset prometheus-alertmanager -n monitoring
```

---

## 4️⃣ Eliminar DaemonSets

Para eliminar el DaemonSet de `prometheus-node-exporter`:

```bash
kubectl delete daemonset prometheus-prometheus-node-exporter -n monitoring
```

---

## 5️⃣ Eliminar Servicios

Para eliminar todos los servicios de Prometheus y Grafana en el namespace `monitoring`:

```bash
kubectl delete service prometheus-server prometheus-alertmanager prometheus-kube-state-metrics prometheus-node-exporter prometheus-pushgateway grafana -n monitoring
```

---

## 6️⃣ Eliminar PVCs

Para eliminar los PVCs de Prometheus y Grafana:

```bash
kubectl delete pvc grafana-pvc prometheus-pvc -n monitoring
```

Si hay otros PVCs asociados con Longhorn u otros recursos:

```bash
kubectl delete pvc -l app=longhorn -n monitoring
```

---

## 7️⃣ Eliminar Namespace

Finalmente, si deseas eliminar todo el namespace `monitoring` y asegurarte de que todos los recursos asociados se eliminen:

```bash
kubectl delete namespace monitoring
```

---

## 8️⃣ Verificación de la Eliminación

Después de ejecutar estos comandos, puedes verificar que todos los recursos se hayan eliminado con:

```bash
kubectl get all -n monitoring
kubectl get pvc -n monitoring
kubectl get namespaces
```

Si los recursos siguen existiendo, puedes intentar forzar la eliminación del namespace con:

```bash
kubectl delete namespace monitoring --force --grace-period=0
```

---

## 📝 Notas

Estos comandos deberían ayudarte a limpiar todos los recursos relacionados con el monitoreo (Grafana, Prometheus) en tu clúster Kubernetes.
```