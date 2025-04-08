# 📦 Orden de Ejecución – Proyecto `flatcar-k3s-storage-suite`

Este documento define el **orden correcto de ejecución** de los playbooks del proyecto [`flatcar-k3s-storage-suite`](https://github.com/vhgalvez/ansible-monitoring-stack) para configurar el almacenamiento NFS y Longhorn en un clúster Kubernetes con K3s sobre Flatcar Linux.

---

## ✅ Requisitos Previos

- Las máquinas virtuales deben estar encendidas y accesibles por SSH.
- El archivo `inventory/hosts.ini` debe estar correctamente configurado.
- Tienes acceso SSH sin contraseña mediante clave privada.
- `kubectl` debe estar configurado en el nodo `master1` (para aplicar etiquetas y desplegar recursos en K8s).

---

## 🚀 Orden de Ejecución

### 1️⃣ Configurar el nodo de almacenamiento (`storage1`) con LVM + NFS

Este playbook crea volúmenes lógicos, monta los puntos de montaje y exporta rutas NFS.

```bash
sudo ansible-playbook -i [hosts.ini](http://_vscodecontentref_/0) playbooks/nfs_config.yml
```

Aquí tienes el contenido en formato Markdown corregido y estructurado:

```markdown
# 📦 Orden de Ejecución – Proyecto `flatcar-k3s-storage-suite`

Este documento define el **orden correcto de ejecución** de los playbooks del proyecto [`flatcar-k3s-storage-suite`](https://github.com/vhgalvez/ansible-monitoring-stack) para configurar el almacenamiento NFS y Longhorn en un clúster Kubernetes con K3s sobre Flatcar Linux.

---

## ✅ Requisitos Previos

- Las máquinas virtuales deben estar encendidas y accesibles por SSH.
- El archivo `inventory/hosts.ini` debe estar correctamente configurado.
- Tienes acceso SSH sin contraseña mediante clave privada.
- `kubectl` debe estar configurado en el nodo `master1` (para aplicar etiquetas y desplegar recursos en K8s).

---

## 🚀 Orden de Ejecución

### 1️⃣ Configurar el nodo de almacenamiento (`storage1`) con LVM + NFS

Este playbook crea volúmenes lógicos, monta los puntos de montaje y exporta rutas NFS.

```bash
sudo ansible-playbook -i hosts.ini playbooks/nfs_config.yml
```

📌 Se crean y exportan los siguientes directorios:

- `/srv/nfs/postgresql` – Para PostgreSQL (PVC tipo RWX)
- `/srv/nfs/shared` – Para carpetas compartidas entre pods (PVC tipo RWX)
- `/mnt/longhorn-disk` – Para respaldos de Longhorn, tokens, etc.

---

### 2️⃣ Preparar nodos worker para Longhorn

Este playbook formatea y monta los discos adicionales (`/dev/vdb`) en los nodos worker y configura `/mnt/longhorn-disk`.

```bash
sudo ansible-playbook -i hosts.ini playbooks/longhorn_worker_disk_setup.yml
```

📌 Asegúrate de que cada nodo worker tiene un disco adicional conectado como `/dev/vdb`.

---

### 3️⃣ Etiquetar nodos worker desde `master1`

Este playbook usa `kubectl` en el nodo `master1` para etiquetar los nodos con `longhorn=enabled`, permitiendo que Longhorn los use como almacenamiento.

```bash
sudo ansible-playbook -i hosts.ini playbooks/label_longhorn_nodes_from_master.yml
```

📌 Este paso es crítico para que Longhorn detecte y use los nodos.

---

### 4️⃣ Instalar Longhorn en Kubernetes

Este playbook instala Longhorn como sistema de almacenamiento distribuido en el clúster.

```bash
sudo ansible-playbook -i hosts.ini playbooks/install_longhorn.yml
```

📌 Asegúrate de que `kubectl` esté correctamente configurado y tenga permisos administrativos.

---

### 5️⃣ (Opcional) Limpiar toda la configuración

Este playbook desmonta discos, borra volúmenes lógicos y limpia las rutas de NFS, sin afectar el sistema base.

```bash
sudo ansible-playbook -i hosts.ini playbooks/playbook_cleanup.yml
```

---

## 🧭 Resumen

| Paso | Descripción                          | Playbook                                      |
|------|--------------------------------------|----------------------------------------------|
| 1️⃣  | Configurar LVM y exportar NFS        | `playbooks/nfs_config.yml`                   |
| 2️⃣  | Preparar discos para Longhorn        | `playbooks/longhorn_worker_disk_setup.yml`   |
| 3️⃣  | Etiquetar nodos para Longhorn        | `playbooks/label_longhorn_nodes_from_master.yml` |
| 4️⃣  | Instalar Longhorn en K3s             | `playbooks/install_longhorn.yml`             |
| 5️⃣  | (Opcional) Limpiar configuración     | `playbooks/playbook_cleanup.yml`             |

---

## 📝 Notas

Este flujo permite una configuración persistente y replicada para almacenamiento en Kubernetes.

Se recomienda ejecutar estos pasos justo después de desplegar el clúster y antes de instalar aplicaciones que usen PVCs.

```