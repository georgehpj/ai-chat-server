#!/bin/bash

# Server Setup Script for Alibaba Cloud ECS
# This script sets up a fresh ECS instance with Docker and necessary dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🔧 Setting up server environment...${NC}"

# Update system packages
echo -e "${YELLOW}📦 Updating system packages...${NC}"
if command -v yum &> /dev/null; then
    # CentOS/RHEL
    sudo yum update -y
    sudo yum install -y yum-utils
elif command -v apt-get &> /dev/null; then
    # Ubuntu/Debian
    sudo apt-get update -y
    sudo apt-get upgrade -y
fi

# Install Docker
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}🐳 Installing Docker...${NC}"
    if command -v yum &> /dev/null; then
        # CentOS/RHEL
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
    elif command -v apt-get &> /dev/null; then
        # Ubuntu/Debian
        curl -fsSL https://get.docker.com -o get-docker.sh
        sudo sh get-docker.sh
        rm get-docker.sh
    fi
    
    sudo systemctl start docker
    sudo systemctl enable docker
    sudo usermod -aG docker $USER
    
    echo -e "${GREEN}✅ Docker installed successfully${NC}"
else
    echo -e "${GREEN}✅ Docker is already installed${NC}"
fi

# Install Docker Compose (optional, if using docker-compose)
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose installed${NC}"
fi

# Install Git (if not already installed)
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Git...${NC}"
    if command -v yum &> /dev/null; then
        sudo yum install -y git
    elif command -v apt-get &> /dev/null; then
        sudo apt-get install -y git
    fi
fi

# Install Node.js (for running scripts, optional)
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}📦 Installing Node.js...${NC}"
    curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
    if command -v yum &> /dev/null; then
        sudo yum install -y nodejs
    elif command -v apt-get &> /dev/null; then
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
    fi
fi

# Create application directory
APP_DIR="/opt/math-notes-api"
if [ ! -d "$APP_DIR" ]; then
    echo -e "${YELLOW}📁 Creating application directory...${NC}"
    sudo mkdir -p $APP_DIR
    sudo chown $USER:$USER $APP_DIR
fi

# Configure firewall (if using firewalld)
if command -v firewall-cmd &> /dev/null; then
    echo -e "${YELLOW}🔥 Configuring firewall...${NC}"
    sudo firewall-cmd --permanent --add-port=3000/tcp
    sudo firewall-cmd --reload
fi

# Configure ufw (if using ufw)
if command -v ufw &> /dev/null; then
    echo -e "${YELLOW}🔥 Configuring UFW firewall...${NC}"
    sudo ufw allow 3000/tcp
fi

echo -e "${GREEN}✅ Server setup completed!${NC}"
echo -e "${YELLOW}⚠️  Note: You may need to log out and log back in for Docker group changes to take effect.${NC}"
echo -e "${GREEN}📝 Next steps:${NC}"
echo -e "   1. Clone your repository to ${APP_DIR}"
echo -e "   2. Create .env file with your configuration"
echo -e "   3. Run ./scripts/deploy.sh to deploy"