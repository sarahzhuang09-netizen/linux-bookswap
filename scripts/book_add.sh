#!/bin/bash
# book_add.sh - 添加书籍信息
# 负责人：张梦琪

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
LOG_FILE="$DATA_DIR/../logs/operations.log"

# 确保数据目录存在
mkdir -p "$DATA_DIR" "$(dirname "$LOG_FILE")"

# 如果CSV不存在，创建表头
if [ ! -f "$BOOKS_CSV" ]; then
    echo "书名,作者,价格,联系方式,状态,登记时间" > "$BOOKS_CSV"
fi

echo "===== 添加书籍信息 ====="

# 读取输入
read -p "请输入书名: " title
if [ -z "$title" ]; then
    echo "错误：书名不能为空"
    exit 1
fi

read -p "请输入作者: " author
if [ -z "$author" ]; then
    echo "错误：作者不能为空"
    exit 1
fi

read -p "请输入价格（元）: " price
if ! echo "$price" | grep -qE '^[0-9]+(\.[0-9]+)?$'; then
    echo "错误：价格必须为数字"
    exit 1
fi

read -p "请输入联系方式: " contact
if [ -z "$contact" ]; then
    echo "错误：联系方式不能为空"
    exit 1
fi

# 检查书名是否已存在
if grep -q "^$title," "$BOOKS_CSV" 2>/dev/null; then
    echo "警告：书名「$title」已存在，是否继续？(y/n)"
    read -p "" confirm
    if [ "$confirm" != "y" ]; then
        echo "已取消"
        exit 0
    fi
fi

# 写入数据
DATE=$(date '+%Y-%m-%d')
echo "$title,$author,$price,$contact,出售,$DATE" >> "$BOOKS_CSV"

# 记录日志
echo "[$(date '+%Y-%m-%d %H:%M:%S')] ADD_BOOK: 书名=$title 作者=$author 价格=$price 联系=$contact" >> "$LOG_FILE"

echo "✓ 书籍「$title」添加成功！"
