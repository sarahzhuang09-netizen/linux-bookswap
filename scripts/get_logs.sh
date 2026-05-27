#!/bin/bash
# get_logs.sh - 读取最近100条操作日志，输出JSON

LOG_FILE="$(dirname "$0")/../logs/operations.log"

if [ ! -f "$LOG_FILE" ]; then
    echo '{"ok":true,"lines":[]}'
    exit 0
fi

# 用python安全地转义JSON字符串数组
tail -100 "$LOG_FILE" | python3 -c "
import sys, json
lines = [l.rstrip('\n') for l in sys.stdin.readlines()]
lines.reverse()
print(json.dumps({'ok': True, 'lines': lines}, ensure_ascii=False))
"
