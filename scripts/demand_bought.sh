#!/bin/bash
# demand_bought.sh - 标记需求为已买到
# 用法: demand_bought.sh <书名> <user_id>

DATA_DIR="$(dirname "$0")/../data"
DEMANDS_CSV="$DATA_DIR/demands.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

TITLE="$1"
USER_ID="$2"

if [ -z "$TITLE" ] || [ -z "$USER_ID" ]; then
    echo '{"ok":false,"msg":"参数不足"}'
    exit 1
fi

FOUND=$(awk -F',' -v t="$TITLE" -v u="$USER_ID" 'NR>1 && $1==t && $5==u && $4!="已买到" {found=1} END {print found+0}' "$DEMANDS_CSV")
if [ "$FOUND" -eq 0 ]; then
    echo '{"ok":false,"msg":"未找到该需求或无权操作"}'
    exit 1
fi

TMP_FILE=$(mktemp)
awk -F',' -v t="$TITLE" -v u="$USER_ID" 'BEGIN{OFS=","} NR==1{print;next} $1==t && $5==u && $4!="已买到" {$4="已买到"} {print}' "$DEMANDS_CSV" > "$TMP_FILE"
mv "$TMP_FILE" "$DEMANDS_CSV"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] MARK_BOUGHT: user=${USER_ID} 书名=${TITLE}" >> "$LOG_FILE"

echo "{\"ok\":true,\"msg\":\"「${TITLE}」已标记为已买到\"}"
