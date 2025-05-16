#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

EXEC_USER=${SUDO_USER:-$(whoami)}  # Usuario real que llamó al script

# Ejecuta un comando como el usuario original (no root)
as_user() {
  sudo -u "$EXEC_USER" -- "$@"
}

# Paso 1: instalar dependencias (puede requerir permisos root)
sudo ./01_dependencies.sh

# Paso 2: compilar Angular sin root
as_user ./02_compile_frontend.sh

# Paso 3: compilar backend sin root
as_user ./03_compile_backend.sh

# Paso 4-7: ejecución como root (creación BD, admin, agentes, instalación)
for step in 04_prepare_db 05_add_admin_user 06_setup_agents 07_install_service; do
  echo -e "\n===== Ejecutando $step.sh ====="
  sudo "./$step.sh"
done

echo -e "\n🎉  Instalación completa. Accede a http://$(ip -4 addr show scope global \
        | awk '{print $2}' | cut -d/ -f1 | head -n1):8080\n"
