#!/bin/bash
# stats.sh - 统计信息，输出JSON

DATA_DIR="$(dirname "$0")/../data"
LOG_FILE="$(dirname "$0")/../logs/operations.log"

python3 - "$DATA_DIR" "$LOG_FILE" << 'PYEOF'
import sys, csv, os, json

data_dir, log_file = sys.argv[1], sys.argv[2]
books_csv   = os.path.join(data_dir, "books.csv")
demands_csv = os.path.join(data_dir, "demands.csv")

# 书籍统计
prices = []
if os.path.exists(books_csv):
    with open(books_csv, newline="", encoding="utf-8") as f:
        for row in csv.DictReader(f):
            try: prices.append(float(row.get("价格") or row.get("price", 0)))
            except: pass

b_total    = len(prices)
avg_price  = round(sum(prices)/b_total, 1) if prices else 0
max_price  = max(prices) if prices else 0
min_price  = min(prices) if prices else 0

# 需求统计
d_total = 0
if os.path.exists(demands_csv):
    with open(demands_csv, newline="", encoding="utf-8") as f:
        d_total = sum(1 for _ in csv.DictReader(f))

# 日志统计
log_total = add_count = del_count = match_count = 0
if os.path.exists(log_file):
    with open(log_file, encoding="utf-8") as f:
        for line in f:
            log_total += 1
            if "ADD_BOOK"    in line: add_count   += 1
            if "DELETE_BOOK" in line: del_count   += 1
            if "MATCH"       in line: match_count += 1

print(json.dumps({
    "ok": True,
    "books":   {"total": b_total, "avg_price": avg_price, "max_price": max_price, "min_price": min_price},
    "demands": {"total": d_total},
    "logs":    {"total": log_total, "add": add_count, "delete": del_count, "match": match_count}
}, ensure_ascii=False))
PYEOF
