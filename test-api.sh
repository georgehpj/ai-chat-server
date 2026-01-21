#!/bin/bash

# API Test Script
# Usage: ./test-api.sh [base_url]
# Example: ./test-api.sh http://localhost:3000

BASE_URL=${1:-http://localhost:3000}

echo "🧪 Testing Math Notes API at $BASE_URL"
echo ""

# Test 1: Health Check
echo "1. Testing Health Check..."
curl -s "$BASE_URL/health" | jq '.' || echo "❌ Health check failed"
echo ""

# Test 2: Vision Health Check
echo "2. Testing Vision Health Check..."
curl -s "$BASE_URL/api/vision/health" | jq '.' || echo "❌ Vision health check failed"
echo ""

# Test 3: Extract Text (OCR)
echo "3. Testing Text Extraction..."
curl -s -X POST "$BASE_URL/api/vision/extract-text" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20241022/emyrja/dog_and_girl.jpeg"
  }' | jq '.' || echo "❌ Text extraction failed"
echo ""

# Test 4: General Image Analysis
echo "4. Testing General Image Analysis..."
curl -s -X POST "$BASE_URL/api/vision/analyze" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20241022/emyrja/dog_and_girl.jpeg",
    "prompt": "图中描绘的是什么景象?"
  }' | jq '.' || echo "❌ Image analysis failed"
echo ""

# Test 5: Math Problem Analysis
echo "5. Testing Math Problem Analysis..."
curl -s -X POST "$BASE_URL/api/vision/analyze-math" \
  -H "Content-Type: application/json" \
  -d '{
    "image": "https://help-static-aliyun-doc.aliyuncs.com/file-manage-files/zh-CN/20241022/emyrja/dog_and_girl.jpeg"
  }' | jq '.' || echo "❌ Math problem analysis failed"
echo ""

echo "✅ All tests completed!"