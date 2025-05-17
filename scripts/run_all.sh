#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"

EXEC_USER=${SUDO_USER:-$(whoami)}  # Usuario real que llamó al script

# Ejecuta un comando como el usuario original (no root)
as_user() {
  sudo -u "$EXEC_USER" -- "$@"
}

# ──────────────── Título bonito ────────────────
echo -e "\n\e[36m╔════════════════════════════════════════════╗\e[0m"
echo -e "\e[36m║     🚀 Instalador de R-SNORT FRONTEND       ║\e[0m"
echo -e "\e[36m╚════════════════════════════════════════════╝\e[0m"

# Paso 1: instalar dependencias (puede requerir permisos root)
echo -e "\n\e[34m🔧 Instalando dependencias...\e[0m"
sudo ./01_dependencies.sh

# Paso 2: compilar Angular sin root
echo -e "\n\e[34m🧱 Compilando frontend Angular...\e[0m"
as_user ./02_compile_frontend.sh

# Paso 3: compilar backend sin root
echo -e "\n\e[34m🧱 Compilando backend Spring Boot...\e[0m"
as_user ./03_compile_backend.sh

# Paso 4-7: ejecución como root (creación BD, admin, agentes, instalación)
for step in 04_prepare_db 05_add_admin_user 06_setup_agents 07_install_service; do
  echo -e "\n\e[36m===== Ejecutando $step.sh =====\e[0m"
  sudo "./$step.sh"
done

# ──────────────── Fin bonito ────────────────
IP=$(ip -4 -o addr show scope global | awk '{print $4}' | cut -d/ -f1 | head -n1)
echo -e "\n\e[32m🎉 Instalación completada con éxito\e[0m"
echo -e "\e[34m🌐 Accede ahora a: http://$IP:8080\e[0m\n"