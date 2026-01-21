require('dotenv').config({ path: process.env.ENV_FILE || '.local.env' });

const config = {
  // OpenAI API Configuration
  dashscope: {
    apiKey: process.env.DASHSCOPE_API_KEY || '',
    baseURL: process.env.DASHSCOPE_BASE_URL || 'https://dashscope.aliyuncs.com/compatible-mode/v1',
    visionModel: process.env.VISION_MODEL || 'qwen3-vl-plus'
  },
  
  // Server Configuration
  server: {
    port: parseInt(process.env.PORT || '3000', 10),
    nodeEnv: process.env.NODE_ENV || 'development'
  },
  
  // CORS Configuration
  cors: {
    origins: process.env.CORS_ORIGINS 
      ? process.env.CORS_ORIGINS.split(',').map(origin => origin.trim())
      : ['http://localhost:3000']
  },
  
  // Rate Limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10), // 15 minutes
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10)
  }
};

// Validate required environment variables
if (!config.dashscope.apiKey && config.server.nodeEnv === 'production') {
  console.warn('Warning: DASHSCOPE_API_KEY is not set!');
}

module.exports = config;