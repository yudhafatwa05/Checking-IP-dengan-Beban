#!/usr/bin/env bash

FOLDER="${1:-.}"
COUNT=100
SIZE=1400
DELAY=0.2

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_lpr_test_${timestamp}.log"

TMPFILE=$(mktemp)
grep -hEv '^\s*(#|$)' "$FOLDER"/*.txt 2>/dev/null | sort -u > "$TMPFILE"

if [[ ! -s "$TMPFILE" ]]; then
  echo "IP tidak ditemukan di folder: $FOLDER"
  rm -f "$TMPFILE"
  exit 1
fi

spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  while ps -p $pid > /dev/null 2>&1; do
    local temp=${spinstr#?}
    printf " [%c]  Testing..." "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\r"
  done
  printf "                    \r"
}

echo "=== LPR NETWORK TEST ===" | tee -a "$OUTFILE"
echo

while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  printf "🔹 %s " "$host"

  ping -c $COUNT -s $SIZE -i $DELAY -W 2 "$host" > /tmp/ping_result.$$ 2>/dev/null &
  PID=$!

  spinner $PID
  wait $PID

  RESULT=$(grep "packet loss" /tmp/ping_result.$$)
  LOSS=$(echo "$RESULT" | awk -F',' '{print $3}' | awk '{print $1}' | tr -d '%')

  if [[ -z "$LOSS" ]]; then
    STATUS="❌ NO RESPONSE"
  elif (( $(echo "$LOSS == 0" | bc -l) )); then
    STATUS="✅ RECOMMENDED"
  elif (( $(echo "$LOSS <= 1" | bc -l) )); then
    STATUS="✅ SAFE"
  elif (( $(echo "$LOSS <= 3" | bc -l) )); then
    STATUS="⚠️ WARNING"
  else
    STATUS="❌ NOT RECOMMENDED"
  fi

  echo "Packet Loss: ${LOSS}% → $STATUS" | tee -a "$OUTFILE"

done < "$TMPFILE"

rm -f "$TMPFILE" /tmp/ping_result.$$

echo
echo "Selesai. Log disimpan di: $OUTFILE disini ga ya ges ya "
