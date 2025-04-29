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

# 📘 Documentación: Acceso Remoto al Clúster K3s desde Nodo de Administración

## 🎯 Objetivo

Permitir que el nodo de administración (`physical1`) se comunique con el API Server del clúster K3s utilizando `kubectl`, Ansible y módulos como `kubernetes.core.k8s`.

---

## 🖥️ Nodo de Administración: `physical1`

### ✅ Paso 1: Obtener el archivo `k3s.yaml` desde `master1`

El archivo `k3s.yaml` contiene la configuración necesaria (`kubeconfig`) para acceder al API Server de Kubernetes. Ejecuta el siguiente comando para copiarlo desde el nodo `master1`:

```bash
sudo scp -i /root/.ssh/cluster_k3s/shared/id_rsa_shared_cluster core@10.17.4.21:/etc/rancher/k3s/k3s.yaml /home/victory/k3s.yaml
```

---

### ✅ Paso 2: Crear la carpeta de configuración de `kubectl`

Crea la carpeta donde se almacenará la configuración de `kubectl`:

```bash
mkdir -p ~/.kube
```

---

### ✅ Paso 3: Copiar `k3s.yaml` como configuración por defecto

Copia el archivo `k3s.yaml` a la ubicación predeterminada de configuración de `kubectl` y ajusta los permisos:

```bash
cp /home/victory/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
```

---

### ✅ Paso 4: Corregir la IP del servidor en `kubeconfig`

El archivo original apunta a `127.0.0.1`, pero desde `physical1` se necesita acceder al API Server mediante la IP del VIP del HAProxy (`10.17.5.10`). Corrige la IP con el siguiente comando:

```bash
sudo sed -i 's/127.0.0.1/10.17.5.10/g' ~/.kube/config
```

---

### ✅ Paso 5: Verificar acceso al clúster (ignorando certificados autofirmados)

Verifica que puedes acceder al clúster utilizando `kubectl` con el siguiente comando:

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

### Exportar configuración para Ansible

Para que Ansible reconozca la configuración de `kubectl`, exporta la variable de entorno:

```bash
export K8S_AUTH_KUBECONFIG=~/.kube/config
```





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
✅ Dónde se almacena la clave SSH
Cuando generas la clave SSH con este comando:

bash
Copiar
Editar
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_monitoring
Se generan dos archivos:


Archivo	Descripción
~/.ssh/id_rsa_monitoring	🔐 Clave privada → No se debe compartir.
~/.ssh/id_rsa_monitoring.pub	🔓 Clave pública → Esta sí se copia al servidor.
📁 Ubicación:
Estas claves se almacenan localmente en tu equipo (ejemplo: Ubuntu WSL), en:

bash
Copiar
Editar
/home/<tu_usuario>/.ssh/id_rsa_monitoring
🔧 Cómo crear el usuario monitoring en Rocky Linux
En tu servidor Rocky Linux, ejecuta lo siguiente:

bash
Copiar
Editar
sudo adduser monitoring
sudo passwd monitoring
# (Escribe una contraseña segura, opcional si usarás solo SSH Key)

# Crear carpeta SSH
sudo mkdir -p /home/monitoring/.ssh
sudo chmod 700 /home/monitoring/.ssh
sudo chown -R monitoring:monitoring /home/monitoring/.ssh
🚀 Copiar la clave pública al usuario
En tu Ubuntu (WSL), usa:

bash
Copiar
Editar
ssh-copy-id -i ~/.ssh/id_rsa_monitoring.pub monitoring@192.168.0.19
O manualmente:

bash
Copiar
Editar
cat ~/.ssh/id_rsa_monitoring.pub | ssh monitoring@192.168.0.19 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
📁 Verifica en el servidor
La clave pública quedará almacenada en:

swift
Copiar
Editar
/home/monitoring/.ssh/authorized_keys
🧪 Verifica acceso SSH
Desde tu WSL:

bash
Copiar
Editar
ssh -i ~/.ssh/id_rsa_monitoring monitoring@192.168.0.19
Deberías entrar sin pedir contraseña.

🛠️ Ajusta el inventory de Ansible
En tu inventory/hosts.ini:

ini
Copiar
Editar
[controller]
192.168.0.19 ansible_user=monitoring ansible_ssh_private_key_file=~/.ssh/id_rsa_monitoring ansible_become=true ansible_become_method=sudo


# 📊 ansible-monitoring-stack

Automatización del despliegue de **Prometheus** y **Grafana** en un clúster Kubernetes (K3s) utilizando **Ansible**, **Helm** y almacenamiento persistente con **Longhorn**.  
Este proyecto forma parte del stack [FlatcarMicroCloud](https://github.com/vhgalvez/FlatcarMicroCloud).

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

# Prometheus: Accede a la UI de Prometheus en el puerto 9091 (externo)

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




# Iniciar Grafana y Prometheus

sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3000:80 > ~/grafana.log 2>&1 &


sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:80 > ~/prometheus.log 2>&1 &



# ✅ Port-forward de Grafana
sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3000:3000 > ~/grafana.log 2>&1 &

# ✅ Port-forward de Prometheus
sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:9091 > ~/prometheus.log 2>&1 &




http://192.168.0.15:3000   → Grafana  
http://192.168.0.15:9091   → Prometheus


ansible-playbook -i inventory/hosts.ini playbook/03_update_scrape_targets.yml




# Para Grafana
sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3000:3000 > ~/grafana.log 2>&1 &

# Prometheus
sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:9091 > ~/prometheus.log 2>&1 &


sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3000:3000 > ~/grafana.log 2>&1 &

sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:9091 > ~/prometheus.log 2>&1 &




sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:80 > ~/prometheus.log 2>&1 &


sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3000:80 > ~/grafana.log 2>&1 &





sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 3000:3000 > ~/grafana.log 2>&1 & disown

sudo env "PATH=$PATH" KUBECONFIG=$HOME/.kube/config nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 9091:80 > ~/prometheus.log 2>&1 & disown




kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 32001:80

kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 32002:3000


# muestra el estado de los port-forwards
 ps aux | grep port-forward

# ✅ Matar antiguos
sudo pkill -f "kubectl port-forward"



nohup kubectl port-forward -n monitoring svc/prometheus-server --address 0.0.0.0 32001:80 > /tmp/prometheus-port-forward.log 2>&1 &

nohup kubectl port-forward -n monitoring svc/grafana --address 0.0.0.0 32002:3000 > /tmp/grafana-port-forward.log 2>&1 &

