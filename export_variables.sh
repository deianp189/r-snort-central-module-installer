#!/usr/bin/env bash
set -euo pipefail

# Ruta del archivo de configuración con credenciales
DB_CNF="/etc/rsnort-agent/db.cnf"

# Validación mínima
if [[ ! -f "$DB_CNF" ]]; then
  echo "[ERROR] No se encontró el archivo $DB_CNF" >&2
  exit 1
fi

# Exportar variables de entorno desde el archivo db.cnf
export RSNORT_DB_USERNAME=$(awk -F= '/^user/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$DB_CNF")
export RSNORT_DB_PASSWORD=$(awk -F= '/^password/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$DB_CNF")
export RSNORT_DB_NAME=$(awk -F= '/^database/ {gsub(/^[ \t]+|[ \t]+$/, "", $2); print $2}' "$DB_CNF")
