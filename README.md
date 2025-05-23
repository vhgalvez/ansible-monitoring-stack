# ansible-monitoring-stack

**Automatización del despliegue de Prometheus y Grafana en un clúster Kubernetes (K3s) utilizando Ansible, Helm y almacenamiento persistente con Longhorn.**

Este proyecto forma parte del stack [FlatcarMicroCloud](https://github.com/vhgalvez/FlatcarMicroCloud), ofreciendo una solución automatizada para monitorear nodos y servicios con Prometheus y Grafana. Además, permite la instalación de **Node Exporter** para la recolección de métricas de los nodos, todo gestionado con **Ansible**.

---

## 📦 Estructura del Proyecto

```bash
📦 ansible-monitoring-stack/
│
├── 📚 Documentación
│   └── doc/
│       ├── doc.md                # Explicación técnica (cómo funciona todo)
│       └── structure.md          # Estructura explicada
│
├── 📁 Inventario y variables
│   ├── inventory/hosts.ini       # Inventario estático de nodos
│   └── group_vars/all.yml        # Variables globales (ej: contraseña de Grafana)
│
├── ▶️ Playbooks por paso
│   └── playbook/
│       ├── 01_install_local_tools.yml
│       ├── 02_setup_kubeconfig.yml
│       ├── 03_install_monitoring_stack.yml
│       ├── 04_install_node_exporter.yml
│       ├── 05_update_scrape_targets.yml
│
├── ♻️ Otras automatizaciones
│   ├── update_monitoring_targets.yml
│   ├── uninstall_stack.yml
│   └── install_stack.yml (opcional alias)
│
├── 📦 Roles
│   └── roles/
│       ├── grafana/
│       ├── prometheus/
│       └── node_exporter/
│
├── 🖥 Scripts útiles (forwarding local)
│   └── sh-forward/
│       ├── start-monitoring.sh
│       ├── stop-monitoring.sh
│       └── doc.md
│
├── 📄 Logs locales (ignorar en .gitignore si deseas)
│   ├── prometheus.log
│   └── grafana.log
│
├── LICENSE
└── README.md
```

---

## ⚙️ Requisitos

Antes de comenzar, asegúrate de tener lo siguiente instalado y configurado:

- Acceso por SSH a nodos masters.
- Acceso a `kubectl` y `helm` en el nodo desde el que ejecutarás los playbooks.
- Kubernetes en funcionamiento (K3s o estándar).
- PVCs con `storageClassName: longhorn` para persistencia de datos.
- Colecciones necesarias de Ansible:

```bash
ansible-galaxy collection install community.kubernetes kubernetes.core
```

---

## 🎯 Ejecución

### 1. Instalar el stack completo

Este playbook instalará Prometheus y Grafana en Kubernetes, configurará PVCs para persistencia de datos y utilizará Helm para gestionar los charts de ambas herramientas:

```bash
sudo ansible-playbook -i inventory/hosts.ini playbook/deploy_monitoring_stack.yml
```

### 2. Actualizar los targets de scrape de Prometheus

Si necesitas añadir o actualizar los nodos a los que Prometheus realizará scrape de métricas, ejecuta:

```bash
sudo ansible-playbook -i inventory/hosts.ini playbook/03_update_scrape_targets.yml
```

### 3. Eliminar el stack de monitoreo

Para eliminar todo el stack, incluyendo Prometheus y Grafana:

```bash
sudo ansible-playbook -i inventory/hosts.ini playbook/uninstall_stack.yml
```

### 4. Forwarding de puertos para interfaces de usuario (opcional)

Si deseas acceder a las interfaces de Grafana o Prometheus localmente, puedes usar `kubectl port-forward`:

```bash
# Para Grafana
sudo bash sh-forward/start-monitoring.sh

# Para Prometheus
sudo bash sh-forward/stop-monitoring.sh
```

---

## 🔧 Playbooks incluidos

### Playbook principal

```bash
playbook/deploy_monitoring_stack.yml
```

Este playbook realiza las siguientes tareas:

- Crea el namespace `monitoring` (si no existe).
- Despliega PVCs para Prometheus y Grafana.
- Instala los charts de Helm para `grafana/grafana` y `prometheus-community/prometheus`.
- Configura almacenamiento persistente con Longhorn.

### Otros Playbooks útiles

- **Actualizar los targets de scrape de Prometheus:**

```bash
ansible-playbook -i inventory/hosts.ini playbook/03_update_scrape_targets.yml
```

- **Eliminar todo el stack:**

```bash
ansible-playbook -i inventory/hosts.ini playbook/uninstall_stack.yml
```

---

## 📊 Acceso a las interfaces de usuario

- **Grafana:** Accede a la UI de Grafana en el puerto 3000 (por defecto):

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

- **Prometheus:** Accede a la UI de Prometheus en el puerto 9091 (por defecto):

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9091:9091
```

---

## ✨ Configuración de Grafana y Prometheus

1. **Configurar Prometheus como fuente de datos en Grafana:**

   - Ingresa a Grafana en [http://localhost:3000](http://localhost:3000).
   - Usa las credenciales por defecto (`admin/admin`).
   - Añade Prometheus como fuente de datos en Grafana:
     - URL de Prometheus: `http://localhost:9090`.

2. **Cargar un Dashboard popular:**

   Grafana tiene varios dashboards preconfigurados para monitorear Node Exporter, Kubernetes y más. Puedes importarlos usando los IDs de dashboard:

   - Node Exporter Full: `1860`
   - K8s Cluster Monitoring: `315`
   - Prometheus Stats: `2`

---

## 🖼 Imágenes de referencia

![Monitoreo 1](image/monitoreo_01.png)
![Monitoreo 2](image/monitoreo_02.png)
![Monitoreo 3](image/monitoreo_03.png)
![Grafana 1](image/monitoreo_grafana_01.png)
![Grafana 2](image/monitoreo_grafana_02.png)
![Prometheus](image/monitoreo_prometheus.png)

---

## 📦 Notas adicionales

- Grafana quedará accesible internamente en el namespace `monitoring` con el password definido en `group_vars/all.yml`.
- Los PVCs se almacenan usando Longhorn en modo `ReadWriteOnce`.
- Para exponer Grafana o Prometheus mediante Traefik o NodePort, revisa los servicios correspondientes en Kubernetes.

---

## 🛠 Gestión de port-forwards

### Mostrar el estado de los port-forwards:

```bash
ps aux | grep port-forward
```

### Matar procesos antiguos:

```bash
sudo pkill -f "kubectl port-forward"
```

### Configurar nuevos port-forwards:

```bash
nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 32001:80 > /tmp/prometheus-port-forward.log 2>&1 &

nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 32002:3000 > /tmp/grafana-port-forward.log 2>&1 &
```

---

## instalar el stack completo
```bash
sudo ansible-playbook -i inventory/hosts.ini playbook/deploy_monitoring_stack.yml
```

## ✨ Créditos

Este proyecto fue creado como parte del stack FlatcarMicroCloud y tiene como objetivo simplificar la gestión de monitoreo en Kubernetes usando herramientas de código abierto y automatización con Ansible.

**Autor:** [@vhgalvez](https://github.com/vhgalvez)
