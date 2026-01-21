#!/bin/bash

# Math Notes API Deployment Script for Alibaba Cloud ECS
# Usage: ./scripts/deploy.sh [environment]
# Example: ./scripts/deploy.sh production

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-production}
PROJECT_NAME="math-notes-api"
DOCKER_IMAGE="${PROJECT_NAME}:latest"
CONTAINER_NAME="math-notes-api"
PORT=3000

echo -e "${GREEN}🚀 Starting deployment for ${ENVIRONMENT}...${NC}"

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Load environment variables if .env file exists
if [ -f .env ]; then
    echo -e "${YELLOW}📋 Loading environment variables from .env...${NC}"
    export $(cat .env | grep -v '^#' | xargs)
fi

# Build Docker image
echo -e "${GREEN}🔨 Building Docker image...${NC}"
docker build -t ${DOCKER_IMAGE} .

# Stop and remove existing container if it exists
if [ $(docker ps -a -q -f name=${CONTAINER_NAME}) ]; then
    echo -e "${YELLOW}🛑 Stopping existing container...${NC}"
    docker stop ${CONTAINER_NAME} || true
    docker rm ${CONTAINER_NAME} || true
fi

# Run new container
echo -e "${GREEN}▶️  Starting new container...${NC}"
docker run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p ${PORT}:3000 \
    -e NODE_ENV=production \
    -e PORT=3000 \
    -e DASHSCOPE_API_KEY="${DASHSCOPE_API_KEY}" \
    -e DASHSCOPE_BASE_URL="${DASHSCOPE_BASE_URL:-https://dashscope.aliyuncs.com/compatible-mode/v1}" \
    -e VISION_MODEL="${VISION_MODEL:-qwen3-vl-plus}" \
    -e CORS_ORIGINS="${CORS_ORIGINS:-*}" \
    ${DOCKER_IMAGE}

# Wait for container to be healthy
echo -e "${YELLOW}⏳ Waiting for service to be healthy...${NC}"
sleep 5

# Check if container is running
if [ $(docker ps -q -f name=${CONTAINER_NAME}) ]; then
    echo -e "${GREEN}✅ Container is running${NC}"
    
    # Health check
    echo -e "${YELLOW}🏥 Checking health...${NC}"
    sleep 3
    if curl -f http://localhost:${PORT}/health > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Health check passed${NC}"
    else
        echo -e "${YELLOW}⚠️  Health check failed, but container is running${NC}"
    fi
    
    echo -e "${GREEN}📊 Container status:${NC}"
    docker ps -f name=${CONTAINER_NAME}
    
    echo -e "${GREEN}📝 Container logs:${NC}"
    docker logs --tail 20 ${CONTAINER_NAME}
else
    echo -e "${RED}❌ Container failed to start${NC}"
    echo -e "${RED}📝 Error logs:${NC}"
    docker logs ${CONTAINER_NAME} || true
    exit 1
fi

echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${GREEN}🌐 API is available at: http://localhost:${PORT}${NC}"