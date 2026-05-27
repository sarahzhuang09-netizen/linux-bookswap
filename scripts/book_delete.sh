#!/bin/bash
# book_delete.sh - 删除书籍（管理员）
# 用法: book_delete.sh <书名>

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

mkdir -p "$(dirname "$LOG_FILE")"

TITLE="$1"

if [ -z "$TITLE" ]; then
    echo '{"ok":false,"msg":"书名不能为空"}'
    exit 1
fi

if [ ! -f "$BOOKS_CSV" ]; then
    echo '{"ok":false,"msg":"书籍数据文件不存在"}'
    exit 1
fi

# 检查书籍是否存在（跳过表头，精确匹配第一列）
FOUND=$(awk -F',' -v t="$TITLE" 'NR>1 && $1==t {found=1} END {print found+0}' "$BOOKS_CSV")
if [ "$FOUND" -eq 0 ]; then
    echo "{\"ok\":false,\"msg\":\"未找到书籍「${TITLE}」\"}"
    exit 1
fi

# 删除匹配行（保留表头）
TMP_FILE=$(mktemp)
awk -F',' -v t="$TITLE" 'NR==1 || $1!=t' "$BOOKS_CSV" > "$TMP_FILE"
mv "$TMP_FILE" "$BOOKS_CSV"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] DELETE_BOOK: 书名=${TITLE}" >> "$LOG_FILE"

echo "{\"ok\":true,\"msg\":\"已删除「${TITLE}」\"}"
