#!/bin/bash
# request_add.sh - 登记求购需求
# 负责人：徐雪榆

DATA_DIR="$(dirname "$0")/../data"
DEMANDS_CSV="$DATA_DIR/demands.csv"
LOG_FILE="$DATA_DIR/../logs/operations.log"

mkdir -p "$DATA_DIR" "$(dirname "$LOG_FILE")"

if [ ! -f "$DEMANDS_CSV" ]; then
    echo "书名,联系方式,登记时间" > "$DEMANDS_CSV"
fi

echo "===== 登记求购需求 ====="
echo "（如果你有书要卖，请用主菜单选项1「添加书籍」）"
echo ""

read -p "请输入想买的书名: " title
if [ -z "$title" ]; then
    echo "错误：书名不能为空"
    exit 1
fi

read -p "请输入您的联系方式: " contact
if [ -z "$contact" ]; then
    echo "错误：联系方式不能为空"
    exit 1
fi

DATE=$(date '+%Y-%m-%d')
echo "$title,$contact,$DATE" >> "$DEMANDS_CSV"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] ADD_REQUEST: 书名=$title 联系=$contact" >> "$LOG_FILE"

echo ""
echo "✓ 求购需求登记成功：「$title」"
echo "  系统将在 books.csv 中寻找匹配的出售书籍，请选择「执行匹配」查看结果"
