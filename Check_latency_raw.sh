#!/usr/bin/env bash

FOLDER="${1:-.}"
COUNT=100
SIZE=65500
DELAY=0.1

timestamp=$(date '+%Y-%m-%d_%H-%M-%S')
OUTFILE="hasil_lpr_test_${timestamp}.log"

TMPFILE=$(mktemp)
grep -hEv '^\s*(#|$)' "$FOLDER"/*.txt 2>/dev/null | sort -u > "$TMPFILE"

if [[ ! -s "$TMPFILE" ]]; then
  echo "IP tidak ditemukan di folder: $FOLDER"
  rm -f "$TMPFILE"
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
  while ps -p $pid > /dev/null 2>&1; do
    i=$(( (i+1) %4 ))
    printf "\r   Testing... %s" "${spin:$i:1}"
    sleep .1
  done
  printf "\r                    \r"
}

echo -e "\n=== LPR NETWORK TEST ===\n" | tee -a "$OUTFILE"

while IFS= read -r host; do
  [[ -z "$host" ]] && continue

  echo -e "🔹 IP: $host" | tee -a "$OUTFILE"

  ping -c $COUNT -s $SIZE -i $DELAY -W 2 "$host" > /tmp/ping_result.$$ 2>/dev/null &
  PID=$!

  spinner $PID
  wait $PID

  RESULT=$(grep "packet loss" /tmp/ping_result.$$)
  RTT=$(grep "rtt min" /tmp/ping_result.$$)

  LOSS=$(echo "$RESULT" | awk -F',' '{print $3}' | awk '{print $1}' | tr -d '%')
  AVG=$(echo "$RTT" | awk -F'/' '{print $5}')

  if [[ -z "$LOSS" ]]; then
    STATUS="${RED}NO RESPONSE ❌${NC}"
  elif (( $(echo "$LOSS == 0" | bc -l) )); then
    STATUS="${GREEN}RECOMMENDED ✅${NC}"
  elif (( $(echo "$LOSS <= 1" | bc -l) )); then
    STATUS="${GREEN}SAFE ✅${NC}"
  elif (( $(echo "$LOSS <= 3" | bc -l) )); then
    STATUS="${YELLOW}WARNING ⚠️${NC}"
  else
    STATUS="${RED}NOT RECOMMENDED ❌${NC}"
  fi

  echo -e "   Packet Loss : ${LOSS}%"
  echo -e "   Avg Latency : ${AVG} ms"
  echo -e "   Status LPR  : $STATUS"
  echo "--------------------------------------------------" | tee -a "$OUTFILE"

done < "$TMPFILE"

rm -f "$TMPFILE" /tmp/ping_result.$$

echo -e "\nSelesai. Log disimpan di: $OUTFILE\n"
