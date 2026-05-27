#!/bin/bash
# user_register.sh - 注册用户
# 用法: user_register.sh <username> <contact> <password_hash> <user_id> <date>

DATA_DIR="$(dirname "$0")/../data"
USERS_CSV="$DATA_DIR/users.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

mkdir -p "$DATA_DIR" "$(dirname "$LOG_FILE")"

USERNAME="$1"
CONTACT="$2"
PWD_HASH="$3"
USER_ID="$4"
DATE="$5"

if [ -z "$USERNAME" ] || [ -z "$CONTACT" ] || [ -z "$PWD_HASH" ] || [ -z "$USER_ID" ]; then
    echo '{"ok":false,"msg":"参数不足"}'
    exit 1
fi

if [ ! -f "$USERS_CSV" ]; then
    echo "user_id,username,contact,password_hash,created" > "$USERS_CSV"
fi

# 检查用户名是否重复
EXISTS=$(awk -F',' -v u="$USERNAME" 'NR>1 && $2==u {found=1} END {print found+0}' "$USERS_CSV")
if [ "$EXISTS" -eq 1 ]; then
    echo '{"ok":false,"msg":"用户名已被注册"}'
    exit 1
fi

printf '%s,%s,%s,%s,%s\n' "$USER_ID" "$USERNAME" "$CONTACT" "$PWD_HASH" "$DATE" >> "$USERS_CSV"
echo "[$(date '+%Y-%m-%d %H:%M:%S')] REGISTER: user_id=${USER_ID} username=${USERNAME}" >> "$LOG_FILE"

echo "{\"ok\":true,\"user_id\":\"${USER_ID}\",\"username\":\"${USERNAME}\",\"contact\":\"${CONTACT}\"}"
