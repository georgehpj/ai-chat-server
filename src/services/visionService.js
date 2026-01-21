const OpenAI = require('openai');
const axios = require('axios');
const config = require('../config/env');

class VisionService {
  constructor() {
    this.openai = new OpenAI({
      apiKey: config.dashscope.apiKey,
      baseURL: config.dashscope.baseURL
    });
    this.model = config.dashscope.visionModel;
  }

  /**
   * Convert image URL or base64 to proper format for API
   * @param {string} imageInput - URL or base64 string
   * @returns {string} - Properly formatted image URL or data URL
   */
  async prepareImageInput(imageInput) {
    // If it's already a URL, return as is
    if (imageInput.startsWith('http://') || imageInput.startsWith('https://')) {
      return imageInput;
    }
    
    // If it's base64, convert to data URL
    if (imageInput.startsWith('data:image/')) {
      return imageInput;
    }
    
    // Assume it's base64 without prefix
    if (/^[A-Za-z0-9+/=]+$/.test(imageInput)) {
      // Try to detect image format from base64
      // For simplicity, default to jpeg. In production, you might want to detect format
      return `data:image/jpeg;base64,${imageInput}`;
    }
    
    throw new Error('Invalid image input format. Expected URL or base64 string.');
  }

  /**
   * Analyze image with text prompt
   * @param {string|Array} imageInput - Image URL(s) or base64 string(s)
   * @param {string} prompt - Text prompt for image analysis
   * @param {Object} options - Additional options
   * @returns {Promise<Object>} - Analysis result
   */
  async analyzeImage(imageInput, prompt, options = {}) {
    try {
      // Support single image or multiple images
      const images = Array.isArray(imageInput) ? imageInput : [imageInput];
      
      // Prepare image content
      const imageContents = await Promise.all(
        images.map(img => this.prepareImageInput(img))
      );

      // Build content array
      const content = [
        ...imageContents.map(imageUrl => ({
          type: 'image_url',
          image_url: {
            url: imageUrl
          }
        })),
        {
          type: 'text',
          text: prompt
        }
      ];

      // Create completion request
      const response = await this.openai.chat.completions.create({
        model: this.model,
        messages: [
          {
            role: 'user',
            content: content
          }
        ],
        ...options
      });

      return {
        success: true,
        content: response.choices[0]?.message?.content || '',
        model: response.model,
        usage: response.usage,
        rawResponse: response
      };
    } catch (error) {
      console.error('Vision API Error:', error);
      throw {
        success: false,
        error: error.message,
        code: error.code || 'UNKNOWN_ERROR',
        details: error.response?.data || null
      };
    }
  }

  /**
   * Extract text from image (OCR-like functionality)
   * @param {string} imageInput - Image URL or base64
   * @returns {Promise<string>} - Extracted text
   */
  async extractText(imageInput) {
    const prompt = '请提取图片中的所有文字内容，保持原有格式和换行。如果图片中没有文字，请返回"未检测到文字"。';
    const result = await this.analyzeImage(imageInput, prompt);
    return result.content;
  }

  /**
   * Analyze math problem from image
   * @param {string} imageInput - Image URL or base64
   * @returns {Promise<Object>} - Math problem analysis
   */
  async analyzeMathProblem(imageInput) {
    const prompt = `请分析这张图片中的数学题目，提取以下信息：
1. 题目类型（选择题、填空题、解答题等）
2. 涉及的数学知识点
3. 题目的完整内容
4. 如果有答案，请提取答案
请以结构化的格式返回分析结果。`;
    
    const result = await this.analyzeImage(imageInput, prompt);
    return {
      ...result,
      extractedText: await this.extractText(imageInput)
    };
  }
}

module.exports = new VisionService();