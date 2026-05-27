#!/bin/bash
# book_add.sh - 添加书籍
# 用法: book_add.sh <书名> <作者> <价格> <联系方式> <user_id>

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

mkdir -p "$DATA_DIR" "$(dirname "$LOG_FILE")"

TITLE="$1"
AUTHOR="$2"
PRICE="$3"
CONTACT="$4"
USER_ID="$5"

# 参数校验
if [ -z "$TITLE" ] || [ -z "$AUTHOR" ] || [ -z "$PRICE" ] || [ -z "$CONTACT" ] || [ -z "$USER_ID" ]; then
    echo '{"ok":false,"msg":"所有字段均为必填"}'
    exit 1
fi

if ! echo "$PRICE" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    echo '{"ok":false,"msg":"价格必须为数字"}'
    exit 1
fi

# 初始化CSV表头
if [ ! -f "$BOOKS_CSV" ]; then
    echo "书名,作者,价格,联系方式,状态,登记时间,user_id" > "$BOOKS_CSV"
fi

DATE=$(date '+%Y-%m-%d')
printf '%s,%s,%s,%s,%s,%s,%s\n' "$TITLE" "$AUTHOR" "$PRICE" "$CONTACT" "出售" "$DATE" "$USER_ID" >> "$BOOKS_CSV"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ADD_BOOK: user=${USER_ID} 书名=${TITLE} 价格=${PRICE}" >> "$LOG_FILE"

echo "{\"ok\":true,\"msg\":\"书籍「${TITLE}」添加成功\"}"
