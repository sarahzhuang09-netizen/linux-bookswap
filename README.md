# Linux 二手书共享与交换平台

基于Linux Shell脚本的校内二手书共享与交换命令行工具集。

## 项目结构

```
bookswap/
├── bookswap.sh          # 主控脚本（入口）
├── scripts/
│   ├── book_add.sh      # 添加书籍
│   ├── book_delete.sh   # 删除书籍
│   ├── book_list.sh     # 列出书籍
│   ├── request_add.sh   # 登记求购/出售需求
│   ├── match.sh         # 自动匹配
│   ├── daily_report.sh  # 生成每日报告
│   └── stats.sh         # 数据统计
├── data/
│   ├── books.csv        # 书籍数据
│   └── demands.csv      # 需求数据
├── logs/
│   └── operations.log   # 操作日志（运行后自动生成）
└── reports/             # 每日报告（运行后自动生成）
```

## 快速开始

```bash
# 添加执行权限
chmod +x bookswap.sh scripts/*.sh

# 启动主菜单
bash bookswap.sh
```

## 各模块单独使用

```bash
# 添加书籍
bash scripts/book_add.sh

# 查看所有书籍
bash scripts/book_list.sh

# 登记需求
bash scripts/request_add.sh

# 执行匹配
bash scripts/match.sh

# 查看统计
bash scripts/stats.sh

# 生成今日报告
bash scripts/daily_report.sh
```

## 配置定时任务（crontab）

每天早上8点自动生成报告：

```bash
# 编辑crontab
crontab -e

# 添加以下行（替换为实际路径）
0 8 * * * /bin/bash /path/to/bookswap/scripts/daily_report.sh >> /path/to/bookswap/logs/cron.log 2>&1
```

## 技术栈

- Bash Shell 脚本
- Linux 命令：grep、awk、sed、date、wc
- 数据格式：CSV（逗号分隔）
- 定时任务：crontab

## 小组分工

| 成员 | 负责模块 | 脚本文件 |
|------|----------|----------|
| 张梦琪 | 书籍信息管理 | book_add.sh, book_delete.sh, book_list.sh |
| 徐雪榆 | 匹配与请求处理 | request_add.sh, match.sh |
| 庄霁璇 | 系统工具与自动化 | daily_report.sh, stats.sh, crontab配置 |
