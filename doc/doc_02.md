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
