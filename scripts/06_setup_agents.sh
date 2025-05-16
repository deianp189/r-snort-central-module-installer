#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/00_common.sh"
exec > >(tee -a "$LOG_DIR/06_setup_agents.log") 2>&1

AGENTS_DIR=/etc/rsnort-backend
AGENTS_JSON=$AGENTS_DIR/agents.json
install -d -m 755 "$AGENTS_DIR"

IP_LOCAL=$(detect_ip)
declare -a A; A+=("{\"id\":\"central\",\"ip\":\"$IP_LOCAL\"}")

echo "[INFO] Agente central añadido automáticamente: central ($IP_LOCAL)"

COUNT=0
while true; do
  read -rp "¿Añadir otro agente? (y/N) " yn
  [[ "$yn" =~ ^[Yy]$ ]] || break
  read -rp "  ID: " ID
  read -rp "  IP: " IP
  A+=("{\"id\":\"$ID\",\"ip\":\"$IP\"}")
  ((COUNT++))
done

printf "[\n" >"$AGENTS_JSON"
for ((i=0; i<${#A[@]}; i++)); do
  SEP=$([[ $i -lt $((${#A[@]}-1)) ]] && echo ,)
  printf "  %s%s\n" "${A[$i]}" "$SEP" >>"$AGENTS_JSON"
done
printf "]\n" >>"$AGENTS_JSON"

chmod 644 "$AGENTS_JSON"

if (( COUNT > 0 )); then
  log "✔ agents.json creado en $AGENTS_JSON con $((COUNT + 1)) agentes:"
else
  log "✔ agents.json creado en $AGENTS_JSON solo con el módulo central."
fi

for agent in "${A[@]}"; do
  echo " - $(echo $agent | jq -r '.id') @ $(echo $agent | jq -r '.ip')"
done
