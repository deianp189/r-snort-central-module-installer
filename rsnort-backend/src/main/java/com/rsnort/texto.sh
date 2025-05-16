#!/usr/bin/env bash
set -euo pipefail

# Ruta base donde se encuentran las clases Java
BASE_DIR="."

# Archivo final combinado
OUTPUT_FILE="combined_rsnort_classes.java"

# Limpiar archivo de salida si existe
rm -f "$OUTPUT_FILE"

# Buscar y concatenar todas las clases Java (ordenadas por nombre de archivo)
find "$BASE_DIR" -type f -name "*.java" | sort | while read -r file; do
  echo "/** ======= $file ======= */" >> "$OUTPUT_FILE"
  cat "$file" >> "$OUTPUT_FILE"
  echo -e "\n\n" >> "$OUTPUT_FILE"
done

echo "✅ Clases combinadas en: $OUTPUT_FILE"
