#!/bin/bash
# request_add.sh - 登记求购需求
# 用法: request_add.sh <书名> <联系方式> <user_id>

DATA_DIR="$(dirname "$0")/../data"
DEMANDS_CSV="$DATA_DIR/demands.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

mkdir -p "$DATA_DIR" "$(dirname "$LOG_FILE")"

TITLE="$1"
CONTACT="$2"
USER_ID="$3"

if [ -z "$TITLE" ] || [ -z "$CONTACT" ] || [ -z "$USER_ID" ]; then
    echo '{"ok":false,"msg":"书名、联系方式和用户ID均为必填"}'
    exit 1
fi

if [ ! -f "$DEMANDS_CSV" ]; then
    echo "书名,联系方式,登记时间,状态,user_id" > "$DEMANDS_CSV"
fi

DATE=$(date '+%Y-%m-%d')
printf '%s,%s,%s,%s,%s\n' "$TITLE" "$CONTACT" "$DATE" "求购中" "$USER_ID" >> "$DEMANDS_CSV"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ADD_REQUEST: user=${USER_ID} 书名=${TITLE}" >> "$LOG_FILE"

echo "{\"ok\":true,\"msg\":\"求购需求「${TITLE}」已登记\"}"
