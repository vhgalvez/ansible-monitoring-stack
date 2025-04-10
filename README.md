# 📊 ansible-monitoring-stack

Automatización completa del despliegue de **Prometheus** y **Grafana** en un clúster Kubernetes (K3s) utilizando **Ansible**, **Helm** y **PVCs personalizados** con almacenamiento persistente `Longhorn`.

---

## 📦 Estructura del Proyecto

```bash
ansible-monitoring-stack/
├── group_vars/
│   └── all.yml                  # Variables globales (ej. contraseña Grafana)
├── inventory/
│   └── hosts.ini                # Inventario Ansible de tu clúster Kubernetes
├── playbook_monitoring.yml     # Playbook principal
└── roles/
    ├── grafana/
    │   ├── tasks/
    │   │   └── main.yml         # Despliegue de Grafana
    │   └── templates/           # Plantillas Jinja2 para PVC y configuración
    │       ├── grafana-deployment.yaml.j2
    │       └── grafana-pvc.yaml.j2
    └── prometheus/
        ├── tasks/
        │   └── main.yml         # Despliegue de Prometheus
        └── templates/           # Plantilla PVC Prometheus
            └── prometheus-pvc.yaml.j2
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
