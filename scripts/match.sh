#!/bin/bash
# match.sh - 匹配求购需求与在售书籍，输出JSON
# 用法: match.sh [user_id]   （有参数则只匹配该用户的需求）

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
DEMANDS_CSV="$DATA_DIR/demands.csv"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

mkdir -p "$(dirname "$LOG_FILE")"

FILTER_UID="$1"

if [ ! -f "$DEMANDS_CSV" ] || [ ! -f "$BOOKS_CSV" ]; then
    echo '{"ok":true,"matched":[],"unmatched":[]}'
    exit 0
fi

# 用Python做复杂的JSON匹配输出，awk难以安全构建嵌套JSON
python3 - "$BOOKS_CSV" "$DEMANDS_CSV" "$FILTER_UID" "$LOG_FILE" << 'PYEOF'
import sys, csv, json
from datetime import datetime

books_csv, demands_csv, filter_uid, log_file = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4]

# 读在售书籍
book_map = {}
with open(books_csv, newline="", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        if row.get("状态") == "出售":
            book_map.setdefault(row["书名"], []).append({
                "title": row["书名"], "author": row["作者"],
                "price": row["价格"], "contact": row["联系方式"]
            })

matched, unmatched = [], []
with open(demands_csv, newline="", encoding="utf-8") as f:
    for row in csv.DictReader(f):
        if filter_uid and row.get("user_id") != filter_uid:
            continue
        d_title = row["书名"]
        hits = [b for k, bl in book_map.items() for b in bl if d_title in k or k in d_title]
        entry = {"demand_title": d_title, "demand_contact": row["联系方式"], "demand_status": row.get("状态", "")}
        if hits:
            entry["books"] = hits
            matched.append(entry)
        else:
            unmatched.append(entry)

ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
with open(log_file, "a", encoding="utf-8") as f:
    f.write(f"[{ts}] MATCH: 成功={len(matched)} 失败={len(unmatched)}\n")

print(json.dumps({"ok": True, "matched": matched, "unmatched": unmatched}, ensure_ascii=False))
PYEOF
