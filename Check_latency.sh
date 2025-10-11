#!/usr/bin/env bash
# ------------------------------------------------------------
# check_latency_beban.sh
# Cek latency (ping) untuk semua IP di semua file *.txt dalam folder tertentu
# dengan ukuran paket besar (65500 bytes)
# ------------------------------------------------------------

FOLDER="${1:-.}"   # Default: current directory
COUNT=4            # Jumlah ping per IP
SIZE=65500         # Ukuran paket (bytes)

# Pastikan folder ada
if [[ ! -d "$FOLDER" ]]; then
  echo "Folder tidak ditemukan: $FOLDER"
  echo "Usage: $0 /path/to/folder"
  exit 1
fi

# Ambil semua IP unik dari file .txt
TMPFILE=$(mktemp)
grep -hEv '^\s*(#|$)' "$FOLDER"/*.txt 2>/dev/null | sort -u > "$TMPFILE"

if [[ ! -s "$TMPFILE" ]]; then
  echo "Tidak ada IP ditemukan di folder: $FOLDER"
  rm -f "$TMPFILE"
  exit 0
fi

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_ping_beban_${timestamp}.csv"

echo "HOST,LOSS(%),AVG_RTT(ms)" > "$OUTFILE"

echo
echo "=============================================================="
echo "📡  HASIL PING DENGAN BEBAN $SIZE bytes"
echo "=============================================================="
echo

# Loop setiap IP
while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  echo "🔹 Menguji $host ..."
  out=$(ping -c $COUNT -s $SIZE -W 2 "$host" 2>/dev/null)

  if [[ -z "$out" ]]; then
    echo -e "❌  Tidak ada respons dari $host"
    echo "$host,100,N/A" >> "$OUTFILE"
    echo
    continue
  fi

  # Ambil packet loss
  loss=$(echo "$out" | grep -oE '[0-9]+% packet loss' | grep -oE '[0-9]+' || echo "100")

  # Ambil avg RTT
  avg=$(echo "$out" | awk -F'/' '/rtt/ {print $5}')
  if [[ -z "$avg" ]]; then avg="N/A"; fi

  # Cetak hasil ke terminal
  printf "%-30s %8s %14s\n" "HOST" "LOSS%" "AVG_RTT(ms)"
  echo "--------------------------------------------------------------"
  printf "%-30s %8s %14s\n" "$host" "$loss" "$avg"
  echo "--------------------------------------------------------------"
  echo

  # Simpan ke CSV
  echo "$host,$loss,$avg" >> "$OUTFILE"

done < "$TMPFILE"

rm -f "$TMPFILE"

echo "✅  Selesai! Hasil disimpan di: $OUTFILE"
echo
