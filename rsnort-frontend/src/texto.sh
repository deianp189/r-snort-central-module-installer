#!/bin/bash

BASE_DIR="."
OUTPUT_FILE="codigo_unificado.txt"

> "$OUTPUT_FILE"

find "$BASE_DIR" -type f \( -name "*.ts" -o -name "*.html" \) \
  ! -name "*.spec.ts" ! -name "*.css" | while read -r file; do
    echo "==== CONTENIDO DE: $file ====" >> "$OUTPUT_FILE"
    cat "$file" >> "$OUTPUT_FILE"
    echo -e "\n\n" >> "$OUTPUT_FILE"
done

echo "✅ Código combinado en $OUTPUT_FILE"
