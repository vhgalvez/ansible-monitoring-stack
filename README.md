


# Instalar colecciones necesarias
sudo ansible-galaxy collection install community.kubernetes kubernetes.core

# Instalar stack completo
sudo ansible-playbook -i inventory/hosts.ini  playbook/deploy_monitoring_stack.yml

# Añadir nuevos nodos a monitoreo
sudo ansible-playbook -i inventory/hosts.ini update_monitoring_targets.yml

# Eliminar todo
sudo ansible-playbook -i inventory/hosts.ini uninstall_stack.yml

# Forward para UI (opcional)
sudo bash sh-forward/start-monitoring.sh
