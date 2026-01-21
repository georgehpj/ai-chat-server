const visionService = require('../services/visionService');

class VisionController {
  /**
   * General image analysis endpoint
   * POST /api/vision/analyze
   */
  async analyzeImage(req, res) {
    try {
      const { image, prompt, options } = req.body;

      if (!image) {
        return res.status(400).json({
          success: false,
          error: 'Image is required. Provide image URL or base64 string.'
        });
      }

      if (!prompt) {
        return res.status(400).json({
          success: false,
          error: 'Prompt is required.'
        });
      }

      const result = await visionService.analyzeImage(image, prompt, options);
      
      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      console.error('Analyze image error:', error);
      res.status(error.code === 'UNKNOWN_ERROR' ? 500 : 400).json({
        success: false,
        error: error.error || error.message || 'Failed to analyze image',
        code: error.code
      });
    }
  }

  /**
   * Extract text from image (OCR)
   * POST /api/vision/extract-text
   */
  async extractText(req, res) {
    try {
      const { image } = req.body;

      if (!image) {
        return res.status(400).json({
          success: false,
          error: 'Image is required.'
        });
      }

      const text = await visionService.extractText(image);
      
      res.json({
        success: true,
        data: {
          text,
          image: image.substring(0, 100) + '...' // Return partial image info for reference
        }
      });
    } catch (error) {
      console.error('Extract text error:', error);
      res.status(500).json({
        success: false,
        error: error.error || error.message || 'Failed to extract text'
      });
    }
  }

  /**
   * Analyze math problem from image
   * POST /api/vision/analyze-math
   */
  async analyzeMathProblem(req, res) {
    try {
      const { image } = req.body;

      if (!image) {
        return res.status(400).json({
          success: false,
          error: 'Image is required.'
        });
      }

      const result = await visionService.analyzeMathProblem(image);
      
      res.json({
        success: true,
        data: result
      });
    } catch (error) {
      console.error('Analyze math problem error:', error);
      res.status(500).json({
        success: false,
        error: error.error || error.message || 'Failed to analyze math problem'
      });
    }
  }

  /**
   * Health check endpoint
   * GET /api/vision/health
   */
  async health(req, res) {
    res.json({
      success: true,
      service: 'Vision API',
      status: 'healthy',
      timestamp: new Date().toISOString()
    });
  }
}

module.exports = new VisionController();