#!/bin/bash
# book_delete.sh - 精确删除一条书籍记录
# 用法: book_delete.sh <书名> <作者> <价格> <联系方式> <user_id>

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATA_DIR="$SCRIPT_DIR/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
LOG_FILE="$SCRIPT_DIR/../logs/operations.log"

mkdir -p "$DATA_DIR" "$(dirname "$LOG_FILE")"

if [ ! -f "$BOOKS_CSV" ]; then
    echo '{"ok":false,"msg":"书籍数据文件不存在"}'
    exit 1
fi

python3 - "$BOOKS_CSV" "$1" "$2" "$3" "$4" "$5" "$LOG_FILE" << 'PYEOF'
import sys, csv, json, io
from datetime import datetime

books_csv  = sys.argv[1]
title      = sys.argv[2].strip()
author     = sys.argv[3].strip()
price      = sys.argv[4].strip()
contact    = sys.argv[5].strip()
user_id    = sys.argv[6].strip()
log_file   = sys.argv[7]

with open(books_csv, "r", encoding="utf-8") as f:
    content = f.read().replace('\r\n', '\n').replace('\r', '\n')

reader = csv.DictReader(io.StringIO(content))
fieldnames = reader.fieldnames
rows = []
found = False
for row in reader:
    # 所有字段都匹配才算同一条记录
    if (not found
        and row.get("书名","").strip()    == title
        and row.get("作者","").strip()    == author
        and row.get("价格","").strip()    == price
        and row.get("联系方式","").strip() == contact
        and row.get("user_id","").strip() == user_id):
        found = True   # 精确命中，跳过此行（删除）
    else:
        rows.append(row)

if not found:
    print(json.dumps({"ok": False, "msg": f"未找到书籍「{title}」"}, ensure_ascii=False))
    sys.exit(1)

with open(books_csv, "w", newline="\n", encoding="utf-8") as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
    writer.writeheader()
    writer.writerows(rows)

ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
with open(log_file, "a", encoding="utf-8") as f:
    f.write(f"[{ts}] DELETE_BOOK: 书名={title} 作者={author} user_id={user_id}\n")

print(json.dumps({"ok": True, "msg": f"已删除「{title}」"}, ensure_ascii=False))
PYEOF
