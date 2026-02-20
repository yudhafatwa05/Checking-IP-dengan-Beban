#!/usr/bin/env bash

FOLDER="${1:-.}"
COUNT=100
SIZE=65500
DELAY=1.0

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_packet_loss_${timestamp}.log"

TMPFILE=$(mktemp)
grep -hEv '^\s*(#|$)' "$FOLDER"/*.txt 2>/dev/null | sort -u > "$TMPFILE"

if [[ ! -s "$TMPFILE" ]]; then
  echo "IP tidak ditemukan di folder: $FOLDER"
  rm -f "$TMPFILE"
  exit 1
fi

echo "=== HASIL PACKET LOSS TEST ===" | tee -a "$OUTFILE"
echo

while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  RESULT=$(ping -c $COUNT -s $SIZE -i $DELAY -W 2 "$host" 2>/dev/null \
    | grep "packet loss")

  LOSS=$(echo "$RESULT" | awk -F',' '{print $3}' | awk '{print $1}')

  if [[ -z "$LOSS" ]]; then
    echo "$host -> TIMEOUT / NO RESPONSE ❌" | tee -a "$OUTFILE"
  else
    echo "$host -> Packet Loss: $LOSS" | tee -a "$OUTFILE"
  fi

done < "$TMPFILE"

rm -f "$TMPFILE"

echo
echo "Selesai. Log disimpan di: $OUTFILE ini ya gaes ya "
