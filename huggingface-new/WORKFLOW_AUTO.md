# 自动化工作流

## Cron 任务清单（21个）

### 探活任务（2个）
- `health-check-15`：每小时 :15探活五个目标
- `health-check-45`：每小时 :45探活五个目标

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

### 随机自拍（8个）
- `random-selfie-morning`：06:00-08:30 早间档
- `random-selfie-work_morning`：08:30-12:00 上午工作档
- `random-selfie-lunch`：12:00-14:00 午餐档
- `random-selfie-work_afternoon`：14:00-18:00 下午工作档
- `random-selfie-evening`：18:00-22:00 傍晚档
- `random-selfie-night`：22:00-00:00 夜晚档
- `random-selfie-latenight`：00:00-03:00 深夜档
- `random-selfie-deepnight`：03:00-06:00 黎明档


## 投递规则

- QQ（qqbot）：通过 delivery.channel 自动投递
- 企业微信（wecom-app）
## 探活目标

1. 目标-openaiapi：https://daniellenguyen-cliproxyapi.hf.space/ 和 /v1/models
2. 目标-HF小龙虾：https://emilyreed96989-ccv.hf.space
3. 目标-grokapisougou：https://owenpowell-grok2api.hf.space/v1/models
4.目标-geminiapi：https://antigmanager-xxy.hf.space/health
5. 目标-grokapiqq：https://qqrgok-qqrrok2api.hf.space/v1/models
6. 目标-grokapikuake：https://huggingfacekkgrok2api-kuakegrok2api.hf.space/v1/models
7. 目标-flaresolverr-cf刷新：https://flaresolverr-cjfb.onrender.com

## 探活判断标准

- 正常：任何 HTTP 响应（200/301/400/401/404/500/502 等）= 服务在线
- 异常：仅限网络层错误（timeout、DNS失败、connection refused）

## 心跳检查方式

在容器内执行 `openclaw status` 确认 gateway 和 cron 运行状态。
