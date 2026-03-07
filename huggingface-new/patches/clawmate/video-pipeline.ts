import type { ClawMateConfig } from "./core/types";

export interface GenerateVideoOptions {
  config: ClawMateConfig;
  baseImageUrl: string;
  prompt: string;
  duration?: number;
  aspectRatio?: string;
  logger: any;
}

export interface VideoResult {
  ok: boolean;
  videoUrl?: string;
  previewUrl?: string;
  provider?: string;
  requestId?: string;
  message?: string;
  error?: string;
}

function extractVideoUrl(html: string): { videoUrl: string; previewUrl: string } {
  const videoMatch = html.match(/src="([^"]+\.mp4)"/);
  const previewMatch = html.match(/poster="([^"]+\.jpg)"/);
  
  return {
    videoUrl: videoMatch ? videoMatch[1] : '',
    previewUrl: previewMatch ? previewMatch[1] : ''
  };
}

export async function generateVideo(options: GenerateVideoOptions): Promise<VideoResult> {
  const { config, baseImageUrl, prompt, duration = 6, aspectRatio = "16:9", logger } = options;
  
  const providerName = config.videoProvider || "grokvideosougou";
  const provider = config.providers[providerName];
  
  if (!provider) {
    return {
      ok: false,
      error: `Video provider ${providerName} not found`,
      message: "视频生成配置错误"
    };
  }

  try {
    const requestBody = {
      model: provider.model || "grok-imagine-1.0-video",
      messages: [
        {
          role: "user",
          content: [
            {
              type: "image_url",
              image_url: {
                url: baseImageUrl
              }
            },
            {
              type: "text",
              text: prompt
            }
          ]
        }
      ],
      video_config: {
        aspect_ratio: aspectRatio,
        video_length: duration,
        resolution_name: "480p",
        preset: "normal"
      }
    };

    logger.info("调用视频生成接口", {
      provider: providerName,
      prompt,
      duration,
      aspectRatio
    });

    const response = await fetch(`${provider.baseUrl}/chat/completions`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${provider.apiKey}`
      },
      body: JSON.stringify(requestBody),
      signal: AbortSignal.timeout(provider.timeoutMs || 300000)
    });

    if (!response.ok) {
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    }

    const text = await response.text();
    
    // 从流式响应中提取最后的video标签
    const lines = text.split('\n').filter(line => line.startsWith('data: '));
    let videoHtml = '';
    
    for (const line of lines) {
      if (line === 'data: [DONE]') break;
      
      try {
        const data = JSON.parse(line.substring(6));
        const content = data.choices?.[0]?.delta?.content;
        if (content && content.includes('<video')) {
          videoHtml = content;
        }
      } catch (e) {
        // 忽略解析错误
      }
    }

    if (!videoHtml) {
      throw new Error("未能从响应中提取视频URL");
    }

    const { videoUrl, previewUrl } = extractVideoUrl(videoHtml);

    if (!videoUrl) {
      throw new Error("未能解析视频URL");
    }

    logger.info("视频生成成功", {
      provider: providerName,
      videoUrl,
      previewUrl
    });

    return {
      ok: true,
      videoUrl,
      previewUrl,
      provider: providerName,
      requestId: undefined
    };

  } catch (error) {
    logger.error("视频生成失败", {
      provider: providerName,
      error: error instanceof Error ? error.message : String(error)
    });

    return {
      ok: false,
      provider: providerName,
      requestId: undefined,
      message: "视频生成失败",
      error: error instanceof Error ? error.message : String(error)
    };
  }
}
