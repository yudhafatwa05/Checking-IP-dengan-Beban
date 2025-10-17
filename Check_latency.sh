#!/usr/bin/env bash

FOLDER="${1:-.}"
COUNT=50
SIZE=1472
DELAY=1

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_ping_raw_${timestamp}.log"

TMPFILE=$(mktemp)
grep -hEv '^\s*(#|$)' "$FOLDER"/*.txt 2>/dev/null | sort -u > "$TMPFILE"

if [[ ! -s "$TMPFILE" ]]; then
  echo "❌ IP tidak ditemukan di folder: $FOLDER"
  rm -f "$TMPFILE"
  exit 1
fi

echo "Mulai uji ping (${COUNT} paket / IP, ${SIZE} bytes)"
echo "Log disimpan di: $OUTFILE"
echo "==============================================================" | tee -a "$OUTFILE"

while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  echo "[*] Testing $host..." | tee -a "$OUTFILE"
  echo "--------------------------------------------------------------" | tee -a "$OUTFILE"

  case "$OSTYPE" in
    linux*)
      ping -c "$COUNT" -s "$SIZE" -i "$DELAY" -W 2 "$host" | tee -a "$OUTFILE"
      ;;
    darwin*)  # macOS
      ping -c "$COUNT" -s "$SIZE" "$host" | tee -a "$OUTFILE"
      ;;
    msys*|cygwin*)  # Windows Git Bash
      ping -n "$COUNT" -l "$SIZE" "$host" | tee -a "$OUTFILE"
      ;;
    *)
      echo "❌ OS tidak dikenali, tidak bisa menjalankan ping" | tee -a "$OUTFILE"
      ;;
  esac

  echo -e "\n==============================================================\n" | tee -a "$OUTFILE"
done < "$TMPFILE"

rm -f "$TMPFILE"
echo "✅ Selesai! Semua hasil tersimpan di: $OUTFILE"
