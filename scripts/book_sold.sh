#!/bin/bash
# book_sold.sh - 标记书籍为已出售
# 用法: book_sold.sh <书名> <user_id>

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

TITLE="$1"
USER_ID="$2"

if [ -z "$TITLE" ] || [ -z "$USER_ID" ]; then
    echo '{"ok":false,"msg":"参数不足"}'
    exit 1
fi

if [ ! -f "$BOOKS_CSV" ]; then
    echo '{"ok":false,"msg":"书籍数据文件不存在"}'
    exit 1
fi

# 检查是否存在且属于该用户
FOUND=$(awk -F',' -v t="$TITLE" -v u="$USER_ID" 'NR>1 && $1==t && $7==u {found=1} END {print found+0}' "$BOOKS_CSV")
if [ "$FOUND" -eq 0 ]; then
    echo '{"ok":false,"msg":"未找到该书籍或无权操作"}'
    exit 1
fi

TMP_FILE=$(mktemp)
awk -F',' -v t="$TITLE" -v u="$USER_ID" 'BEGIN{OFS=","} NR==1{print;next} $1==t && $7==u {$5="已出售"} {print}' "$BOOKS_CSV" > "$TMP_FILE"
mv "$TMP_FILE" "$BOOKS_CSV"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] MARK_SOLD: user=${USER_ID} 书名=${TITLE}" >> "$LOG_FILE"

echo "{\"ok\":true,\"msg\":\"「${TITLE}」已标记为已出售\"}"
