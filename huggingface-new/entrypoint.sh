#!/bin/bash
set -e

# 强制使用北京时间（解决 HF Spaces 默认 UTC 导致汇报时间错误）
export TZ="Asia/Shanghai"

CONFIG="/root/.openclaw/openclaw.json"
IP_RECORD="/root/.openclaw/.last_outbound_ip"

# Replace placeholders with secrets from environment
sed -i "s|__CLIPROXY_BASE_URL__|${CLIPROXY_BASE_URL}|g" "$CONFIG"
sed -i "s|__CLIPROXY_API_KEY__|${CLIPROXY_API_KEY}|g" "$CONFIG"
sed -i "s|__WECOM_TOKEN__|${WECOM_TOKEN}|g" "$CONFIG"
sed -i "s|__WECOM_AES_KEY__|${WECOM_AES_KEY}|g" "$CONFIG"
sed -i "s|__WECOM_CORP_ID__|${WECOM_CORP_ID}|g" "$CONFIG"
sed -i "s|__WECOM_APP_TOKEN__|${WECOM_APP_TOKEN}|g" "$CONFIG"
sed -i "s|__WECOM_APP_AES_KEY__|${WECOM_APP_AES_KEY}|g" "$CONFIG"
sed -i "s|__WECOM_APP_SECRET__|${WECOM_APP_SECRET}|g" "$CONFIG"
sed -i "s|__WECOM_APP_ASR_APP_ID__|${WECOM_APP_ASR_APP_ID}|g" "$CONFIG"
sed -i "s|__WECOM_APP_ASR_SECRET_ID__|${WECOM_APP_ASR_SECRET_ID}|g" "$CONFIG"
sed -i "s|__WECOM_APP_ASR_SECRET_KEY__|${WECOM_APP_ASR_SECRET_KEY}|g" "$CONFIG"
sed -i "s|__QQBOT_APP_ID__|${QQBOT_APP_ID}|g" "$CONFIG"
sed -i "s|__QQBOT_CLIENT_SECRET__|${QQBOT_CLIENT_SECRET}|g" "$CONFIG"
sed -i "s|__QQBOT_ASR_APP_ID__|${QQBOT_ASR_APP_ID}|g" "$CONFIG"
sed -i "s|__QQBOT_ASR_SECRET_ID__|${QQBOT_ASR_SECRET_ID}|g" "$CONFIG"
sed -i "s|__QQBOT_ASR_SECRET_KEY__|${QQBOT_ASR_SECRET_KEY}|g" "$CONFIG"
sed -i "s|__FEISHU_APP_ID__|${FEISHU_APP_ID}|g" "$CONFIG"
sed -i "s|__FEISHU_APP_SECRET__|${FEISHU_APP_SECRET}|g" "$CONFIG"
sed -i "s|__FEISHU_VERIFICATION_TOKEN__|${FEISHU_VERIFICATION_TOKEN}|g" "$CONFIG"
sed -i "s|__FEISHU_ENCRYPT_KEY__|${FEISHU_ENCRYPT_KEY}|g" "$CONFIG"
sed -i "s|__VOLCENGINE_ARK_API_KEY__|${VOLCENGINE_ARK_API_KEY}|g" "$CONFIG"
sed -i "s|__VOLCENGINE_PROXY_TOKEN__|${VOLCENGINE_PROXY_TOKEN}|g" "$CONFIG"
sed -i "s|__VOLCENGINE_PROXY_URL__|${VOLCENGINE_PROXY_URL}|g" "$CONFIG"
sed -i "s|__HFOPCF_GROK2API_KEY__|${HFOPCF_GROK2API_KEY}|g" "$CONFIG"
sed -i "s|__HFOPCF_GROK2API_BASE_URL__|${HFOPCF_GROK2API_BASE_URL}|g" "$CONFIG"
sed -i "s|__HFOPQQ_GROK2API_KEY__|${HFOPQQ_GROK2API_KEY}|g" "$CONFIG"
sed -i "s|__HFOPQQ_GROK2API_BASE_URL__|${HFOPQQ_GROK2API_BASE_URL}|g" "$CONFIG"
sed -i "s|__HFOPSOUGOU_GROK2API_KEY__|${HFOPSOUGOU_GROK2API_KEY}|g" "$CONFIG"
sed -i "s|__HFOPSOUGOU_GROK2API_BASE_URL__|${HFOPSOUGOU_GROK2API_BASE_URL}|g" "$CONFIG"

# Fix config file permission (suppress security audit warning)
chmod 600 "$CONFIG"

# 从 Supabase 下载参考图（保护隐私，图片不进代码仓库）
if [ -n "$MAGGIE_REFERENCE_IMAGE_URL" ]; then
  MAGGIE_IMG_DIR="/root/.openclaw/extensions/clawmate-companion/skills/clawmate-companion/assets/characters/maggie/images"
  mkdir -p "$MAGGIE_IMG_DIR"
  curl -fsSL "$MAGGIE_REFERENCE_IMAGE_URL" -o "$MAGGIE_IMG_DIR/reference.png"
  echo "=== Maggie reference image downloaded ==="
fi

# Check outbound IP and notify if changed
CURRENT_IP=$(curl -s --max-time 10 https://ifconfig.me || curl -s --max-time 10 https://api.ipify.org || echo "unknown")
echo "=== HF Space outbound IP: ${CURRENT_IP} ==="

LAST_IP=""
if [ -f "$IP_RECORD" ]; then
  LAST_IP=$(cat "$IP_RECORD")
fi

if [ "$CURRENT_IP" != "unknown" ] && [ "$CURRENT_IP" != "$LAST_IP" ]; then
  echo "$CURRENT_IP" > "$IP_RECORD"

  if [ -n "$WECOM_WEBHOOK_KEY" ]; then
    WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=${WECOM_WEBHOOK_KEY}"

    if [ -z "$LAST_IP" ]; then
      MSG="🦞 OpenClaw HF Space 首次启动\n\n出口IP: ${CURRENT_IP}\n\n请确认该IP已添加到企业微信可信IP白名单中。"
    else
      MSG="⚠️ OpenClaw HF Space 出口IP已变更\n\n旧IP: ${LAST_IP}\n新IP: ${CURRENT_IP}\n\n请立即到企业微信后台更新可信IP白名单，否则 wecom-app 将无法主动发送消息。"
    fi

    curl -s -X POST "$WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"${MSG}\"}}" \
      || echo "Failed to send webhook notification"
  fi
fi

# Start gateway
exec node openclaw.mjs gateway --port 7860 --bind lan --allow-unconfigured
