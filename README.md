# 📊 ansible-monitoring-stack

Automatización del despliegue de **Prometheus** y **Grafana** en un clúster Kubernetes (K3s) utilizando **Ansible**, **Helm** y almacenamiento persistente con **Longhorn**.  
Este proyecto forma parte del stack [FlatcarMicroCloud](https://github.com/vhgalvez/FlatcarMicroCloud).

---

## 📦 Estructura del Proyecto

```bash
ansible-monitoring-stack/
├── ansible.cfg
├── group_vars/
│   └── all.yml                  # Variables globales (ej. contraseña Grafana)
├── inventory/
│   └── hosts.ini                # Inventario Ansible del clúster Kubernetes
├── playbooks/
│   ├── install_helm.yml         # Instalación de Helm
│   ├── install_dependencies.yml # Instalación de Helm, kubectl y pip3
│   ├── site.yml                 # Despliegue completo de la pila de monitorización
│   ├── uninstall_site.yml       # Desinstalación completa de Prometheus y Grafana
│   └── delete_monitoring.yml    # Eliminación específica de Prometheus y Grafana
├── roles/
│   ├── grafana/
│   │   ├── tasks/
│   │   │   └── main.yml
│   │   └── templates/
│   │       ├── grafana-deployment.yaml.j2
│   │       └── grafana-pvc.yaml.j2
│   └── prometheus/
│       ├── tasks/
│       │   └── main.yml
│       └── templates/
│           └── prometheus-pvc.yaml.j2
├── docs/
│   └── README.md                # Documentación detallada del proyecto
└── .gitignore                   # Exclusiones para Git
```

---

## ⚙️ Requisitos

- Acceso por SSH a nodos `masters`
- Acceso a `kubectl` y `helm` en el nodo desde el que ejecutas el playbook
- Kubernetes en funcionamiento (K3s o estándar)
- PVCs con `storageClassName: longhorn`
- Colecciones necesarias de Ansible:

```bash
ansible-galaxy collection install community.kubernetes kubernetes.core
```


📁 Variables
Archivo: group_vars/all.yml

yaml
Copiar
Editar
grafana_admin_password: "SuperSecreta123"
🎯 Ejecución
bash
Copiar
Editar
ansible-playbook -i inventory/hosts.ini playbook_monitoring.yml
Este playbook realiza las siguientes tareas:

Crea el namespace monitoring (si no existe)

Despliega PVCs para Prometheus y Grafana

Instala los charts de Helm:

grafana/grafana

prometheus-community/prometheus

Usa los PVCs creados previamente para persistencia de datos

🗂️ Notas Adicionales
Grafana quedará accesible internamente en el namespace monitoring, con el password definido en group_vars/all.yml

Los PVCs se almacenan usando Longhorn en modo ReadWriteOnce

Revisa el service de Grafana o Prometheus para exponerlo mediante Traefik o NodePort si lo deseas

✨ Créditos
Proyecto creado como parte del stack FlatcarMicroCloud
Autor: @vhgalvez

sudo ansible-playbook install_helm.yml


## Monitorización con `virt-top`

`virt-top` es una herramienta de monitorización para máquinas virtuales que permite visualizar el uso de recursos en tiempo real. Es similar a `top`, pero está diseñada específicamente para entornos de virtualización.
Es útil para supervisar el rendimiento de las máquinas virtuales y los recursos que consumen.

![[Monitorización con `virt-top`](doc/mvs_monitoreo.png)


### Instalación

```bash
sudo dnf install virt-top
```
### Uso básico

```bash
sudo virt-top
```

### Atajos útiles

- h: Ayuda

- c: Ordenar por CPU

- m: Ordenar por Memoria

- 1: Ver vCPUs

- q: Salir



### Requisitos de Python

```bash
sudo pip3 install kubernetes
```

### Requisitos de Ansible

```bash
sudo ansible-galaxy collection install community.kubernetes
```


# Desinstalación de Prometheus y Grafana

```bash
sudo ansible-playbook -i inventory/hosts.ini uninstall_site.yml
```


# Despliegue de Prometheus y Grafana y heml cpmfigracio kubectl en local


```bash
sudo ansible-playbook -i inventory/hosts.ini site.yml
```

# Eliminar Grafana y Prometheus en un clúster K3s

```bash
sudo ansible-playbook -i inventory/hosts.ini delete_monitoring.yml
```

# Acceso a las interfaces de usuario

# Grafana: Accede a la UI de Grafana en el puerto 3001 (externo)

```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000
```

# Prometheus: Accede a la UI de Prometheus en el puerto 9093 (externo)

```bash
kubectl port-forward -n monitoring svc/prometheus-server 9091:9091
```


✳️ Accede correctamente con kubectl port-forward
Usa el puerto expuesto (80) en tu comando, no el targetPort del contenedor.

bash
Copiar
Editar
# Para Grafana
kubectl port-forward -n monitoring svc/grafana 3000:80

# Para Prometheus
kubectl port-forward -n monitoring svc/prometheus-server 9091:80
Esto redirige:

localhost:3000 → svc/grafana:80 → container:3000

localhost:9091 → svc/prometheus-server:80 → container:9090

🧠 Recomendación pro (opcional)
Si quieres usar directamente los puertos 3000 y 9090 en el port-forward, puedes modificar los Service para exponer esos puertos (si no hay conflictos):

Grafana Service:
yaml
Copiar
Editar
ports:
  - name: http
    port: 3000
    targetPort: 3000
Prometheus Service:
yaml
Copiar
Editar
ports:
  - name: http
    port: 9090
    targetPort: 9090



sudo bash -c 'nohup kubectl port-forward -n monitoring svc/grafana 3000:80 > grafana.log 2>&1 &'
sudo bash -c 'nohup kubectl port-forward -n monitoring svc/prometheus-server 9090:80 > prometheus.log 2>&1 &'


sudo nohup kubectl port-forward -n monitoring svc/grafana 3000:80 > grafana.log 2>&1 &

sudo nohup kubectl port-forward -n monitoring svc/prometheus-server 9090:80 > prometheus.log 2>&1 &

ps aux | grep port-forward

pkill -f "kubectl port-forward -n monitoring svc/grafana"
pkill -f "kubectl port-forward -n monitoring svc/prometheus-server"





🧩 PASOS PARA CONFIGURAR PROMETHEUS EN GRAFANA
1. 👉 Ingresar a Grafana
Abre tu navegador y entra a:

arduino
Copiar
Editar
http://localhost:3000
Usuario y contraseña por defecto si no los cambiaste:

pgsql
Copiar
Editar
admin / admin



2. ➕ Añadir Prometheus como Data Source
En el menú lateral izquierdo haz clic en ⚙️ (Settings) → Data sources

Clic en "Add data source"

Selecciona Prometheus



3. 🔌 Configurar conexión
En el campo Prometheus server URL, pon:

arduino
Copiar
Editar
http://localhost:9090
⚠️ Asegúrate de que estás haciendo el port-forward así:

bash
Copiar
Editar
nohup kubectl port-forward -n monitoring svc/prometheus-server 9090:80 > prometheus.log 2>&1 &
No uses 9091 si Prometheus está escuchando por 9090.

5. Cargar un Dashboard popular
Ve a + (Create) → Import

En el campo de "Import via grafana.com" escribe un ID de dashboard.

Dashboard	ID
Node Exporter Full	1860
K8s Cluster Monitoring	315
Prometheus Stats	2