#!/bin/bash
# book_list.sh - 列出所有书籍，输出JSON
# 用法: book_list.sh [user_id]

DATA_DIR="$(dirname "$0")/../data"
BOOKS_CSV="$DATA_DIR/books.csv"
FILTER_UID="$1"

if [ ! -f "$BOOKS_CSV" ]; then
    echo '{"ok":true,"books":[]}'
    exit 0
fi

# tr -d '\r' 处理Windows换行符
tr -d '\r' < "$BOOKS_CSV" | awk -F',' -v uid="$FILTER_UID" '
BEGIN { printf "{\"ok\":true,\"books\":["; first=1 }
NR==1 { next }
{
    while (NF < 7) { $(NF+1)="" }
    title=$1; author=$2; price=$3; contact=$4; status=$5; date=$6; user_id=$7

    if (uid != "" && user_id != uid) next

    gsub(/"/, "\\\"", title);  gsub(/"/, "\\\"", author)
    gsub(/"/, "\\\"", contact); gsub(/"/, "\\\"", status)
    gsub(/"/, "\\\"", user_id)

    if (!first) printf ","
    first=0
    printf "{\"title\":\"%s\",\"author\":\"%s\",\"price\":\"%s\",\"contact\":\"%s\",\"status\":\"%s\",\"date\":\"%s\",\"user_id\":\"%s\"}",
           title, author, price, contact, status, date, user_id
}
END { printf "]}" }
'
