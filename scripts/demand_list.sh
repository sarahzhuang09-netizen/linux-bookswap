#!/bin/bash
# demand_list.sh - 列出需求，输出JSON
# 用法: demand_list.sh [user_id]

DATA_DIR="$(dirname "$0")/../data"
DEMANDS_CSV="$DATA_DIR/demands.csv"
FILTER_UID="$1"

if [ ! -f "$DEMANDS_CSV" ]; then
    echo '{"ok":true,"demands":[]}'
    exit 0
fi

tr -d '\r' < "$DEMANDS_CSV" | awk -F',' -v uid="$FILTER_UID" '
BEGIN { printf "{\"ok\":true,\"demands\":["; first=1 }
NR==1 { next }
{
    while (NF < 5) { $(NF+1)="" }
    title=$1; contact=$2; date=$3; status=$4; user_id=$5

    if (uid != "" && user_id != uid) next

    gsub(/"/, "\\\"", title);   gsub(/"/, "\\\"", contact)
    gsub(/"/, "\\\"", status);  gsub(/"/, "\\\"", user_id)

    if (!first) printf ","
    first=0
    printf "{\"title\":\"%s\",\"contact\":\"%s\",\"date\":\"%s\",\"status\":\"%s\",\"user_id\":\"%s\"}",
           title, contact, date, status, user_id
}
END { printf "]}" }
'
