#!/bin/bash
# book_list.sh - 列出所有书籍
# 负责人：张梦琪

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"

if [ ! -f "$BOOKS_CSV" ]; then
    echo "暂无书籍数据"
    exit 0
fi

echo "===== 当前所有书籍 ====="
echo ""

# 跳过表头，格式化输出
awk -F',' 'NR>1 {
    printf "📚 书名: %-20s 作者: %-15s 价格: %s元\n", $1, $2, $3
    printf "   联系: %-15s 状态: %s  登记日期: %s\n", $4, $5, $6
    print "   ----------------------------------------"
}' "$BOOKS_CSV"

# 统计总数
total=$(awk -F',' 'NR>1' "$BOOKS_CSV" | wc -l)
echo ""
echo "共 $total 本书籍"
