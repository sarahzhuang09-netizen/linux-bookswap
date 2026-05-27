#!/bin/bash
# user_login.sh - 验证用户登录
# 用法: user_login.sh <username> <password_hash>

DATA_DIR="$(dirname "$0")/../data"
USERS_CSV="$DATA_DIR/users.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

USERNAME="$1"
PWD_HASH="$2"

if [ -z "$USERNAME" ] || [ -z "$PWD_HASH" ]; then
    echo '{"ok":false,"msg":"参数不足"}'
    exit 1
fi

if [ ! -f "$USERS_CSV" ]; then
    echo '{"ok":false,"msg":"用户名或密码错误"}'
    exit 1
fi

# 查找匹配的用户
RESULT=$(awk -F',' -v u="$USERNAME" -v p="$PWD_HASH" '
NR>1 && $2==u && $4==p {
    printf "{\"ok\":true,\"user_id\":\"%s\",\"username\":\"%s\",\"contact\":\"%s\"}", $1, $2, $3
    exit
}' "$USERS_CSV")

if [ -z "$RESULT" ]; then
    echo '{"ok":false,"msg":"用户名或密码错误"}'
    exit 1
fi

# 提取user_id写日志
UID_VAL=$(echo "$RESULT" | grep -o '"user_id":"[^"]*"' | cut -d'"' -f4)
echo "[$(date '+%Y-%m-%d %H:%M:%S')] LOGIN: user_id=${UID_VAL} username=${USERNAME}" >> "$LOG_FILE"

echo "$RESULT"
