#!/bin/bash
# 太傻天书每日邮件 — 安装脚本

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_SRC="$SCRIPT_DIR/com.taisha.daily.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.taisha.daily.plist"

echo "🍃 太傻天书 · 每日邮件 · 安装"
echo "================================"
echo ""

# 检查授权码是否已配置
if grep -q "YOUR_AUTH_CODE_HERE" "$SCRIPT_DIR/send_taisha_email.py"; then
    echo "⚠️  你还没有配置 QQ 邮箱授权码。"
    echo ""
    echo "   获取步骤："
    echo "   1. 打开 https://mail.qq.com"
    echo "   2. 设置 → 账户 → POP3/IMAP/SMTP/Exchange/CardDAV/CalDAV服务"
    echo "   3. 找到「SMTP服务」，点击「开启」"
    echo "   4. 按照提示发送短信，获取授权码"
    echo "   5. 把授权码填入脚本中的 AUTH_CODE 变量"
    echo ""
    echo "   文件位置：$SCRIPT_DIR/send_taisha_email.py"
    echo "   找到这一行：AUTH_CODE = \"YOUR_AUTH_CODE_HERE\""
    echo "   替换为：   AUTH_CODE = \"你的授权码\""
    echo ""
    exit 1
fi

# 安装 LaunchAgent
echo "📋 安装定时任务到 LaunchAgents..."
mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DST"

# 卸载旧任务（如果存在）
launchctl unload "$PLIST_DST" 2>/dev/null || true

# 加载新任务
launchctl load "$PLIST_DST"
echo "✅ 定时任务已安装（每天 9:30 自动发送）"
echo ""

# 测试发送
echo "📧 测试发送邮件..."
python3 "$SCRIPT_DIR/send_taisha_email.py"
echo ""

echo "================================"
echo "✅ 安装完成！"
echo ""
echo "常用命令："
echo "  手动发送一次：  python3 $SCRIPT_DIR/send_taisha_email.py"
echo "  查看定时任务：  launchctl list | grep taisha"
echo "  查看运行日志：  cat $SCRIPT_DIR/stdout.log"
echo "  停止定时任务：  launchctl unload $PLIST_DST"
echo "  重新加载任务：  launchctl load $PLIST_DST"
