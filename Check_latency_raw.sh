#!/bin/bash

FILE="${1:-ip_list.txt}"
COUNT=100
SIZE=65500
DELAY=0.1

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_lpr_test_${timestamp}.log"

if [[ ! -f "$FILE" ]]; then
  echo "File tidak ditemukan: $FILE"
  exit 1
fi

# Warna
GREEN="\e[32m"
YELLOW="\e[33m"
RED="\e[31m"
NC="\e[0m"

spinner() {
  local pid=$1
  local spin='-\|/'
  local i=0
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) %4 ))
    printf "\r   Testing... %s" "${spin:$i:1}"
    sleep 0.1
  done
  printf "\r                    \r"
}

echo -e "\n=== LPR NETWORK TEST ===\n" | tee -a "$OUTFILE"

while read -r NAME IP; do
  [[ -z "$NAME" || -z "$IP" ]] && continue

  echo -e "🔹 Gate: $NAME | IP: $IP" | tee -a "$OUTFILE"

  TMP=$(mktemp)

  ping -c "$COUNT" -s "$SIZE" -i "$DELAY" -W 2 "$IP" > "$TMP" 2>/dev/null &
  PID=$!

  spinner "$PID"
  wait "$PID"

  RESULT=$(grep -i "packet loss" "$TMP")
  RTT=$(grep -Ei "rtt|round-trip" "$TMP")

  LOSS=$(echo "$RESULT" | awk -F',' '{print $3}' | tr -dc '0-9.')
  AVG=$(echo "$RTT" | awk -F'/' '{print $5}')

  # Default jika gagal parsing
  [[ -z "$LOSS" ]] && LOSS=100
  [[ -z "$AVG" ]] && AVG="N/A"

  # Logic tanpa bc (lebih aman)
  if [[ "$LOSS" == "100" ]]; then
    STATUS="${RED}NO RESPONSE ❌${NC}"
  elif (( $(printf "%.0f" "$LOSS") == 0 )); then
    STATUS="${GREEN}RECOMMENDED ✅${NC}"
  elif (( $(printf "%.0f" "$LOSS") <= 1 )); then
    STATUS="${GREEN}SAFE ✅${NC}"
  elif (( $(printf "%.0f" "$LOSS") <= 3 )); then
    STATUS="${YELLOW}WARNING ⚠️${NC}"
  else
    STATUS="${RED}NOT RECOMMENDED ❌${NC}"
  fi

  echo -e "   Packet Loss : ${LOSS}%"
  echo -e "   Avg Latency : ${AVG} ms"
  echo -e "   Status LPR  : $STATUS"
  echo "--------------------------------------------------" | tee -a "$OUTFILE"

  rm -f "$TMP"

done < "$FILE"

echo -e "\nSelesai. Log disimpan di: $OUTFILE\n"
