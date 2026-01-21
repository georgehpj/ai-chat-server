#!/bin/bash

# Dockerfile Security Verification Script
# This script builds the image and scans for vulnerabilities

set -e

IMAGE_NAME="math-notes-api:test"
echo "🔍 Building and verifying Docker image..."

# Build the image
echo "📦 Building Docker image..."
docker build -t $IMAGE_NAME .

# Check if trivy is available for vulnerability scanning
if command -v trivy &> /dev/null; then
    echo ""
    echo "🔒 Scanning for vulnerabilities with Trivy..."
    trivy image --severity HIGH,CRITICAL $IMAGE_NAME
elif command -v docker scan &> /dev/null; then
    echo ""
    echo "🔒 Scanning for vulnerabilities with Docker Scan..."
    docker scan $IMAGE_NAME
else
    echo ""
    echo "⚠️  No vulnerability scanner found. Install Trivy or Docker Scan for security checks."
    echo "   Install Trivy: https://aquasecurity.github.io/trivy/latest/getting-started/installation/"
fi

echo ""
echo "✅ Build completed successfully!"
echo "📝 Image: $IMAGE_NAME"