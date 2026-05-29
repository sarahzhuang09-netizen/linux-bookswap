#!/usr/bin/env python3
# app.py - 二手书平台 Flask 后端（Shell脚本调用版）

import os, uuid, hashlib, json, subprocess
from datetime import date
from functools import wraps
from flask import Flask, request, jsonify, session, render_template

app = Flask(__name__)
app.secret_key = "bookswap_secret_2026"

BASE_DIR    = os.path.dirname(os.path.abspath(__file__))
SCRIPTS_DIR = os.path.join(BASE_DIR, "scripts")
ADMIN_PASSWORD = "admin123"

# ── Shell 调用核心函数 ────────────────────────────────────

def run_sh(script_name, *args):
    """
    调用 scripts/<script_name>，将所有 args 作为位置参数传入。
    返回解析后的 JSON dict；若脚本异常则返回 {"ok": False, "msg": 错误信息}。
    """
    script_path = os.path.join(SCRIPTS_DIR, script_name)
    cmd = ["bash", script_path] + [str(a) for a in args]
    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            encoding="utf-8",
            timeout=10,
            cwd=BASE_DIR,
        )
        output = result.stdout.strip()
        if not output:
            return {"ok": False, "msg": result.stderr.strip() or "脚本无输出"}
        return json.loads(output)
    except subprocess.TimeoutExpired:
        return {"ok": False, "msg": "脚本执行超时"}
    except json.JSONDecodeError:
        return {"ok": False, "msg": f"脚本输出非JSON: {result.stdout[:200]}"}
    except Exception as e:
        return {"ok": False, "msg": str(e)}

def hash_pwd(pwd):
    return hashlib.sha256(pwd.encode()).hexdigest()

# ── Auth 装饰器 ───────────────────────────────────────────

def login_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get("user_id"):
            return jsonify({"ok": False, "msg": "请先登录"}), 401
        return f(*args, **kwargs)
    return decorated

def admin_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        if not session.get("is_admin"):
            return jsonify({"ok": False, "msg": "需要管理员权限"}), 403
        return f(*args, **kwargs)
    return decorated

# ── 页面路由 ──────────────────────────────────────────────

@app.route("/")
def index():
    return render_template("index.html")

@app.route("/admin")
def admin():
    return render_template("admin.html")

# ── 用户注册 / 登录 ───────────────────────────────────────

@app.route("/api/user/register", methods=["POST"])
def register():
    d        = request.get_json() or {}
    username = d.get("username", "").strip()
    contact  = d.get("contact",  "").strip()
    password = d.get("password", "").strip()

    if not username or not contact or not password:
        return jsonify({"ok": False, "msg": "用户名、联系方式和密码均为必填"}), 400

    user_id  = str(uuid.uuid4())[:8]
    pwd_hash = hash_pwd(password)
    today    = date.today().strftime("%Y-%m-%d")

    # 调用 Shell 脚本完成注册（写 CSV + 日志）
    data = run_sh("user_register.sh", username, contact, pwd_hash, user_id, today)
    if not data.get("ok"):
        return jsonify(data), 409

    session["user_id"]  = data["user_id"]
    session["username"] = data["username"]
    session["contact"]  = data["contact"]
    return jsonify(data)

@app.route("/api/user/login", methods=["POST"])
def user_login():
    d        = request.get_json() or {}
    username = d.get("username", "").strip()
    password = d.get("password", "").strip()

    if not username or not password:
        return jsonify({"ok": False, "msg": "请填写用户名和密码"}), 400

    # 调用 Shell 脚本验证密码
    data = run_sh("user_login.sh", username, hash_pwd(password))
    if not data.get("ok"):
        return jsonify(data), 401

    session["user_id"]  = data["user_id"]
    session["username"] = data["username"]
    session["contact"]  = data["contact"]
    return jsonify(data)

@app.route("/api/user/logout", methods=["POST"])
def user_logout():
    session.pop("user_id", None)
    session.pop("username", None)
    session.pop("contact",  None)
    return jsonify({"ok": True})

@app.route("/api/user/me")
def user_me():
    uid = session.get("user_id")
    if not uid:
        return jsonify({"ok": False, "logged_in": False})
    return jsonify({
        "ok": True, "logged_in": True,
        "user_id":  uid,
        "username": session.get("username"),
        "contact":  session.get("contact"),
    })

# ── 管理员认证 ────────────────────────────────────────────

@app.route("/api/admin/login", methods=["POST"])
def admin_login():
    d = request.get_json() or {}
    if d.get("password") == ADMIN_PASSWORD:
        session["is_admin"] = True
        return jsonify({"ok": True})
    return jsonify({"ok": False, "msg": "密码错误"}), 401

@app.route("/api/admin/logout", methods=["POST"])
def admin_logout():
    session.pop("is_admin", None)
    return jsonify({"ok": True})

@app.route("/api/admin/check")
def admin_check():
    return jsonify({"is_admin": bool(session.get("is_admin"))})

# ── 书籍接口 ──────────────────────────────────────────────

@app.route("/api/books")
def list_books():
    # book_list.sh 无参数 → 返回全部书籍
    data = run_sh("book_list.sh")
    return jsonify(data)

@app.route("/api/books/mine")
@login_required
def my_books():
    # book_list.sh <user_id> → 只返回该用户的书
    data = run_sh("book_list.sh", session["user_id"])
    return jsonify(data)

@app.route("/api/books", methods=["POST"])
@login_required
def add_book():
    d       = request.get_json() or {}
    title   = d.get("title",   "").strip()
    author  = d.get("author",  "").strip()
    price   = d.get("price",   "").strip()
    contact = d.get("contact", "").strip()

    if not all([title, author, price, contact]):
        return jsonify({"ok": False, "msg": "所有字段均为必填"}), 400

    data = run_sh("book_add.sh", title, author, price, contact, session["user_id"])
    status = 200 if data.get("ok") else 400
    return jsonify(data), status

@app.route("/api/books/<title>/sold", methods=["POST"])
@login_required
def mark_sold(title):
    data = run_sh("book_sold.sh", title, session["user_id"])
    status = 200 if data.get("ok") else 404
    return jsonify(data), status

@app.route("/api/books/delete", methods=["POST"])
@admin_required
def delete_book():
    d = request.get_json() or {}
    # 把所有字段传给脚本做精确匹配
    data = run_sh("book_delete.sh",
                  d.get("title",   ""),
                  d.get("author",  ""),
                  d.get("price",   ""),
                  d.get("contact", ""),
                  d.get("user_id", ""))
    status = 200 if data.get("ok") else 404
    return jsonify(data), status

# ── 需求接口 ──────────────────────────────────────────────

@app.route("/api/demands")
def list_demands():
    data = run_sh("demand_list.sh")
    return jsonify(data)

@app.route("/api/demands/mine")
@login_required
def my_demands():
    data = run_sh("demand_list.sh", session["user_id"])
    return jsonify(data)

@app.route("/api/demands", methods=["POST"])
@login_required
def add_demand():
    d       = request.get_json() or {}
    title   = d.get("title",   "").strip()
    contact = d.get("contact", "").strip()

    if not title or not contact:
        return jsonify({"ok": False, "msg": "书名和联系方式为必填"}), 400

    data = run_sh("request_add.sh", title, contact, session["user_id"])
    status = 200 if data.get("ok") else 400
    return jsonify(data), status

@app.route("/api/demands/<title>/bought", methods=["POST"])
@login_required
def mark_bought(title):
    data = run_sh("demand_bought.sh", title, session["user_id"])
    status = 200 if data.get("ok") else 404
    return jsonify(data), status

# ── 匹配接口 ──────────────────────────────────────────────

@app.route("/api/match/mine")
@login_required
def match_mine():
    # match.sh <user_id> → 只匹配该用户的需求
    data = run_sh("match.sh", session["user_id"])
    return jsonify(data)

@app.route("/api/match")
def match_all():
    # match.sh 无参数 → 全局匹配
    data = run_sh("match.sh")
    return jsonify(data)

# ── 统计 ──────────────────────────────────────────────────

@app.route("/api/stats")
def stats():
    data = run_sh("stats.sh")
    return jsonify(data)

# ── 日志 / 报告（管理员）────────────────────────────────

@app.route("/api/logs")
@admin_required
def get_logs():
    data = run_sh("get_logs.sh")
    return jsonify(data)

@app.route("/api/report", methods=["POST"])
@admin_required
def generate_report():
    data = run_sh("daily_report.sh")
    status = 200 if data.get("ok") else 500
    return jsonify(data), status

# ── 启动 ──────────────────────────────────────────────────

if __name__ == "__main__":
    os.makedirs(os.path.join(BASE_DIR, "data"),    exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, "logs"),    exist_ok=True)
    os.makedirs(os.path.join(BASE_DIR, "reports"), exist_ok=True)
    app.run(debug=True, port=5000)
