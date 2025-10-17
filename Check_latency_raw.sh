#!/usr/bin/env bash

FOLDER="${1:-.}"     # Folder default: current directory
COUNT=100              # Jumlah paket per IP
SIZE=65500            # Ukuran beben pakketbytes
DELAY=1.0             # Delay antar ping (detikk)

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_ping_raw_${timestamp}.log"

# Ambil semua IP unik dari file .txt
TMPFILE=$(mktemp)
grep -hEv '^\s*(#|$)' "$FOLDER"/*.txt 2>/dev/null | sort -u > "$TMPFILE"

if [[ ! -s "$TMPFILE" ]]; then
  echo "IP tidak di temukan: $FOLDER"
  rm -f "$TMPFILE"
  exit 1
fi

echo "Mulai uji ping dengan beban ${SIZE} bytes (${COUNT} paket per IP)"
echo "Log disimpan di: $OUTFILE"
echo "="
echo

while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  echo "🔹 Testing $host dengan paket $SIZE bytes..."
  echo "--------------------------------------------------------------" | tee -a "$OUTFILE"
  echo "🔹 Host: $host" | tee -a "$OUTFILE"
  echo "--------------------------------------------------------------" | tee -a "$OUTFILE"

  # Jalankan ping dan tampilkan hasil mentah
  ping -c $COUNT -s $SIZE -i $DELAY -W 2 "$host" | tee -a "$OUTFILE"

  echo -e "\n" | tee -a "$OUTFILE"
  echo "==============================================================" | tee -a "$OUTFILE"
  echo | tee -a "$OUTFILE"

done < "$TMPFILE"

rm -f "$TMPFILE"

echo "✅ Selesai! Semua hasil tersimpan ya geas ya di: $OUTFILE"
