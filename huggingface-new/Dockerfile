FROM node:22-bookworm

# Install Bun (required for build scripts) and curl (health check)
RUN curl -fsSL https://bun.sh/install | bash
ENV PATH="/root/.bun/bin:${PATH}"

RUN corepack enable

WORKDIR /app

# Clone official OpenClaw repo
RUN git clone --depth 1 https://github.com/openclaw/openclaw.git .

# Install dependencies
RUN pnpm install --no-frozen-lockfile

# Build project
ENV OPENCLAW_A2UI_SKIP_MISSING=1
RUN pnpm build

# Build Control UI
ENV OPENCLAW_PREFER_PNPM=1
RUN pnpm ui:build

ENV NODE_ENV=production

# 强制北京时间（解决 HF Spaces 默认 UTC 导致 agent 汇报时间错误）
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone

# Install openclaw-china channels plugin
RUN node openclaw.mjs plugins install @openclaw-china/channels || echo "Plugin install attempted"

# Install Chromium and dependencies for agent-browser
RUN apt-get update && \
    apt-get install -y --no-install-recommends chromium \
    libxcb-shm0 libx11-xcb1 libx11-6 libxcb1 libxext6 libxrandr2 \
    libxcomposite1 libxcursor1 libxdamage1 libxfixes3 libxi6 libgtk-3-0 \
    libpangocairo-1.0-0 libpango-1.0-0 libatk1.0-0 libcairo-gobject2 \
    libcairo2 libgdk-pixbuf-2.0-0 libxrender1 libasound2 libfreetype6 \
    libfontconfig1 libdbus-1-3 libnss3 libnspr4 libatk-bridge2.0-0 \
    libdrm2 libxkbcommon0 libatspi2.0-0 libcups2 libxshmfence1 libgbm1 && \
    rm -rf /var/lib/apt/lists/*

# Install agent-browser and Playwright
RUN npm install -g agent-browser@latest playwright
ENV PLAYWRIGHT_CHROMIUM_EXECUTABLE_PATH=/usr/bin/chromium
ENV PLAYWRIGHT_BROWSERS_PATH=/root/.cache/ms-playwright

# Install agent-browser skill from ClawHub
RUN npx -y clawhub@latest install agent-browser --force || echo "agent-browser skill install attempted"

# Install ClawMate Companion plugin into global extensions dir (auto-discovered by OpenClaw)
RUN git clone --depth 1 https://github.com/BytePioneer-AI/clawmate.git /tmp/clawmate \
    && mkdir -p /root/.openclaw/extensions \
    && cp -r /tmp/clawmate/packages/clawmate-companion /root/.openclaw/extensions/clawmate-companion \
    && cd /root/.openclaw/extensions/clawmate-companion \
    && npm install --omit=dev --no-audit --no-fund \
    && rm -rf /tmp/clawmate

# Patch clawmate-companion: add boyfriend shooting mode
COPY patches/clawmate/types.ts /root/.openclaw/extensions/clawmate-companion/src/core/types.ts
COPY patches/clawmate/prepare.ts /root/.openclaw/extensions/clawmate-companion/src/core/prepare.ts
COPY patches/clawmate/plugin.ts /root/.openclaw/extensions/clawmate-companion/src/plugin.ts
COPY patches/clawmate/SKILL.md /root/.openclaw/extensions/clawmate-companion/skills/clawmate-companion/SKILL.md
COPY patches/clawmate/SKILL.zh.md /root/.openclaw/extensions/clawmate-companion/skills/clawmate-companion/SKILL.zh.md

# Copy custom character (Maggie) into ClawMate plugin characters directory
# Reference image is downloaded at runtime from Supabase (privacy protection)
COPY characters/maggie /root/.openclaw/extensions/clawmate-companion/skills/clawmate-companion/assets/characters/maggie

# Make openclaw CLI available globally (agent exec tool needs it for `openclaw status` etc.)
RUN printf '#!/bin/sh\nexec node /app/openclaw.mjs "$@"\n' > /usr/local/bin/openclaw && chmod +x /usr/local/bin/openclaw

# Copy pre-configured cron jobs (persistent scheduled tasks)
RUN mkdir -p /root/.openclaw/cron
COPY cron/jobs.json /root/.openclaw/cron/jobs.json

# Copy workspace files: role script, task dispatch, identity, user, agents, tools, bootstrap, memory, heartbeat
RUN mkdir -p /root/.openclaw/workspace
RUN mkdir -p /root/.openclaw/workspace/memory
COPY SOUL.md /root/.openclaw/workspace/SOUL.md
COPY task-dispatch.md /root/.openclaw/workspace/task-dispatch.md
COPY IDENTITY.md /root/.openclaw/workspace/IDENTITY.md
COPY USER.md /root/.openclaw/workspace/USER.md
COPY AGENTS.md /root/.openclaw/workspace/AGENTS.md
COPY TOOLS.md /root/.openclaw/workspace/TOOLS.md
COPY BOOTSTRAP.md /root/.openclaw/workspace/BOOTSTRAP.md
COPY MEMORY.md /root/.openclaw/workspace/MEMORY.md
COPY HEARTBEAT.md /root/.openclaw/workspace/HEARTBEAT.md
COPY WORKFLOW_AUTO.md /root/.openclaw/workspace/WORKFLOW_AUTO.md

# Copy config
RUN mkdir -p /root/.openclaw
COPY openclaw.json /root/.openclaw/openclaw.json

# Copy and set entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# HF Spaces requires port 7860
EXPOSE 7860

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD curl -f http://localhost:7860/ || exit 1

# Use entrypoint to inject secrets at runtime
CMD ["/app/entrypoint.sh"]
