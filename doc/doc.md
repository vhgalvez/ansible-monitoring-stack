📘 Documentación: Acceso remoto al clúster K3s desde nodo de administración
🎯 Objetivo
Permitir que el nodo de administración (physical1) se comunique con el API Server del clúster K3s usando kubectl, Ansible y módulos como kubernetes.core.k8s.

🖥️ Nodo de administración: physical1
✅ Paso 1: Obtener el archivo k3s.yaml desde master1
El archivo k3s.yaml contiene la configuración necesaria (kubeconfig) para acceder al API Server de Kubernetes.

bash
Copiar
Editar
sudo scp -i /home/victory/.ssh/id_rsa_key_cluster_openshift core@10.17.4.21:/etc/rancher/k3s/k3s.yaml /home/victory/k3s.yaml
✅ Paso 2: Crear carpeta de configuración de kubectl
bash
Copiar
Editar
mkdir -p ~/.kube
✅ Paso 3: Copiar k3s.yaml como configuración por defecto
bash
Copiar
Editar
cp /home/victory/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
✅ Paso 4: Corregir la IP del servidor en kubeconfig
El archivo original apunta a 127.0.0.1, pero desde physical1 se necesita acceder por la IP del VIP del HAProxy: 10.17.5.10.

bash
Copiar
Editar
sudo sed -i 's/127.0.0.1/10.17.5.10/g' ~/.kube/config
✅ Paso 5: Verificar acceso al clúster (ignorando certificados autofirmados)
bash
Copiar
Editar
kubectl get nodes --insecure-skip-tls-verify
Resultado esperado:
bash
Copiar
Editar
NAME                            STATUS   ROLES                       AGE    VERSION
master1.cefaslocalserver.com    Ready    control-plane,etcd,master   4d7h   v1.32.3+k3s1
master2.cefaslocalserver.com    Ready    control-plane,etcd,master   4d7h   v1.32.3+k3s1
master3.cefaslocalserver.com    Ready    control-plane,etcd,master   4d7h   v1.32.3+k3s1
storage1.cefaslocalserver.com   Ready    <none>                      4d7h   v1.32.3+k3s1
worker1.cefaslocalserver.com    Ready    <none>                      4d7h   v1.32.3+k3s1
worker2.cefaslocalserver.com    Ready    <none>                      4d7h   v1.32.3+k3s1
worker3.cefaslocalserver.com    Ready    <none>                      4d7h   v1.32.3+k3s1
📌 Notas adicionales
El certificado del API Server es autofirmado, por eso se requiere el flag --insecure-skip-tls-verify (o configurar esa opción en el ~/.kube/config).

Este proceso es esencial para que herramientas como Ansible, Helm y kubectl desde fuera del clúster puedan interactuar con Kubernetes.

Puedes exportar la variable para que Ansible también lo reconozca:

bash
Copiar
Editar
export K8S_AUTH_KUBECONFIG=~/.kube/config