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
