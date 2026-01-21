const express = require('express');
const router = express.Router();
const visionController = require('../controllers/visionController');

// Health check
router.get('/health', visionController.health.bind(visionController));

// General image analysis
router.post('/analyze', visionController.analyzeImage.bind(visionController));

// Extract text from image (OCR)
router.post('/extract-text', visionController.extractText.bind(visionController));

// Analyze math problem
router.post('/analyze-math', visionController.analyzeMathProblem.bind(visionController));

module.exports = router;