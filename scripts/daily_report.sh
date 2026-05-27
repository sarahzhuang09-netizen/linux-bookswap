#!/bin/bash
# daily_report.sh - 生成每日报告，输出JSON（含报告文本）

BASE_DIR="$(dirname "$0")/.."
DATA_DIR="$BASE_DIR/data"
REPORTS_DIR="$BASE_DIR/reports"
LOG_FILE="$BASE_DIR/logs/operations.log"

mkdir -p "$REPORTS_DIR" "$(dirname "$LOG_FILE")"

DATE=$(date '+%Y-%m-%d')
REPORT_FILE="$REPORTS_DIR/report_$DATE.txt"

# 生成报告文本
{
echo "========================================"
echo "     二手书交换平台 每日报告"
echo "     日期：$DATE"
echo "========================================"
echo ""

if [ -f "$DATA_DIR/books.csv" ]; then
    book_total=$(awk -F',' 'NR>1' "$DATA_DIR/books.csv" | wc -l)
    echo "📚 当前在售书籍：$book_total 本"
    echo ""
    echo "--- 书籍列表 ---"
    awk -F',' 'NR>1 {printf "  · %-20s %s元  联系:%s\n", $1,$3,$4}' "$DATA_DIR/books.csv"
    echo ""
else
    echo "📚 暂无在售书籍"
fi

if [ -f "$DATA_DIR/demands.csv" ]; then
    demand_total=$(awk -F',' 'NR>1' "$DATA_DIR/demands.csv" | wc -l)
    echo "📋 需求记录：共 $demand_total 条"
    echo ""
else
    echo "📋 暂无需求记录"
fi

if [ -f "$LOG_FILE" ]; then
    today_ops=$(grep "^\[$DATE" "$LOG_FILE" | wc -l)
    echo "🔧 今日操作记录：$today_ops 条"
    grep "^\[$DATE" "$LOG_FILE" | tail -10 | sed 's/^/  /'
    echo ""
fi

echo "========================================"
echo "报告生成时间：$(date '+%Y-%m-%d %H:%M:%S')"
echo "========================================"
} > "$REPORT_FILE"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] REPORT: 生成每日报告 $REPORT_FILE" >> "$LOG_FILE"

# 把报告内容转义后输出为JSON
CONTENT=$(cat "$REPORT_FILE" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")
printf '{"ok":true,"content":%s,"file":"%s"}\n' "$CONTENT" "$REPORT_FILE"
