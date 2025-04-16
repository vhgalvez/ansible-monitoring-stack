

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
