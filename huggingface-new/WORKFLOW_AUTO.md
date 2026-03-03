# 自动化工作流

## Cron 任务清单（21个）

### 探活任务（2个）
- `health-check-15`：每小时 :15 探活四个目标
- `health-check-45`：每小时 :45 探活四个目标

### 天气简报（2个）
- `weather-morning`：07:25 早间天气简报（梧州市）
- `weather-evening`：22:25 晚间天气简报+明日预报

### 报平安（2个）
- `morning-checkin`：08:35 早间报平安
- `evening-checkin`：23:30 晚间报平安（催远哥哥来睡觉）

### 工作日报（1个）
- `daily-report`：23:55 工作日报总结

### 随机关心（8个）
- `random-care-dawn`：06:50 清晨档
- `random-care-morning`：10:20 上午档
- `random-care-noon`：12:55 午间档
- `random-care-afternoon-1`：15:10 下午档1
- `random-care-afternoon-2`：16:40 下午档2
- `random-care-evening`：18:50 傍晚档
- `random-care-night-1`：21:15 夜间档1
- `random-care-night-2`：22:30 夜间档2

### 随机自拍（6个）
- `random-selfie-morning`：07:30 早间档
- `random-selfie-noon`：12:00 午间档
- `random-selfie-afternoon`：15:30 下午档
- `random-selfie-dusk`：18:00 傍晚档
- `random-selfie-night-1`：20:40 夜间档1
- `random-selfie-night-2`：22:10 睡前档

## 投递规则

- QQ（qqbot）：通过 delivery.channel 自动投递
- 企业微信（wecom-app）
## 探活目标

1. 目标-openaiapi：https://daniellenguyen-cliproxyapi.hf.space/ 和 /v1/models
2. 目标-HF小龙虾：https://emilyreed96989-ccv.hf.space
3. 目标-grokapi：https://owenpowell-grok2api.hf.space/v1/models
4. 目标-geminiapi：https://antigmanager-xxy.hf.space/health

## 探活判断标准

- 正常：任何 HTTP 响应（200/301/400/401/404/500/502 等）= 服务在线
- 异常：仅限网络层错误（timeout、DNS失败、connection refused）

## 心跳检查方式

在容器内执行 `openclaw status` 确认 gateway 和 cron 运行状态。
