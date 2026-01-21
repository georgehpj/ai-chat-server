# Math Notes API Server

基于 Node.js + Express 的数学学习应用后端服务，提供视觉理解功能。

## 功能特性

- 🖼️ 图像视觉理解（基于 qwen3-vl-plus 模型）
- 📝 OCR文字提取
- 📐 数学题目分析
- 🔒 安全性配置（Helmet、CORS、Rate Limiting）
- 🐳 Docker 容器化部署
- 🚀 自动化部署流程

## 技术栈

- **Node.js** 18+
- **Express** 4.18
- **OpenAI Compatible API** (阿里云百炼)
- **Docker** 容器化

## 快速开始

### 本地开发

1. **安装依赖**
```bash
cd server
npm install
```

2. **配置环境变量**

创建 `.local.env` 文件：
```env
DASHSCOPE_API_KEY=your_api_key_here
DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
PORT=3000
NODE_ENV=development
CORS_ORIGINS=http://localhost:3000,http://localhost:5173
```

3. **启动开发服务器**
```bash
npm run dev
```

服务将在 `http://localhost:3000` 启动

### API 端点

#### 1. 健康检查
```bash
GET /health
GET /api/vision/health
```

#### 2. 通用图像分析
```bash
POST /api/vision/analyze
Content-Type: application/json

{
  "image": "https://example.com/image.jpg",  // 或 base64 字符串
  "prompt": "请描述这张图片",
  "options": {}  // 可选
}
```

#### 3. 文字提取（OCR）
```bash
POST /api/vision/extract-text
Content-Type: application/json

{
  "image": "https://example.com/image.jpg"  // 或 base64 字符串
}
```

#### 4. 数学题目分析
```bash
POST /api/vision/analyze-math
Content-Type: application/json

{
  "image": "https://example.com/math-problem.jpg"  // 或 base64 字符串
}
```

## 部署到阿里云 ECS

### 方式一：手动部署

1. **服务器初始化**
```bash
# 在ECS服务器上运行
bash scripts/setup-server.sh
```

2. **克隆代码**
```bash
cd /opt
sudo mkdir -p math-notes-api
sudo chown $USER:$USER math-notes-api
cd math-notes-api
git clone <your-repo-url> .
```

3. **配置环境变量**
```bash
# 创建 .env 文件
cat > .env << EOF
DASHSCOPE_API_KEY=your_api_key_here
DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
NODE_ENV=production
PORT=3000
VISION_MODEL=qwen3-vl-plus
CORS_ORIGINS=*
EOF
```

4. **部署**
```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh production
```

### 方式二：Docker Compose 部署

```bash
# 设置环境变量
export DASHSCOPE_API_KEY=your_api_key_here

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

### 方式三：GitHub Actions 自动化部署

1. **配置 GitHub Secrets**

在 GitHub 仓库设置中添加以下 Secrets：
- `ECS_HOST`: ECS服务器公网IP
- `ECS_USER`: SSH用户名（通常是 `root`）
- `ECS_SSH_KEY`: SSH私钥
- `ECS_PORT`: SSH端口（默认22）
- `DASHSCOPE_API_KEY`: API密钥
- `DASHSCOPE_BASE_URL`: API地址（可选）
- `VISION_MODEL`: 模型名称（可选）
- `CORS_ORIGINS`: CORS配置（可选）

2. **推送代码触发部署**
```bash
git push origin main
```

GitHub Actions 会自动：
- 构建 Docker 镜像
- 通过 SSH 连接 ECS 服务器
- 拉取最新代码
- 部署新版本
- 执行健康检查

## 环境变量说明

| 变量名 | 说明 | 默认值 | 必需 |
|--------|------|--------|------|
| `DASHSCOPE_API_KEY` | 阿里云百炼API密钥 | - | ✅ |
| `DASHSCOPE_BASE_URL` | API基础URL | `https://dashscope.aliyuncs.com/compatible-mode/v1` | ❌ |
| `PORT` | 服务端口 | `3000` | ❌ |
| `NODE_ENV` | 环境模式 | `development` | ❌ |
| `VISION_MODEL` | 视觉模型名称 | `qwen3-vl-plus` | ❌ |
| `CORS_ORIGINS` | CORS允许来源（逗号分隔） | `*` | ❌ |
| `RATE_LIMIT_WINDOW_MS` | 限流时间窗口（毫秒） | `900000` | ❌ |
| `RATE_LIMIT_MAX_REQUESTS` | 限流最大请求数 | `100` | ❌ |

## 安全配置

- ✅ Helmet.js 安全头设置
- ✅ CORS 跨域配置
- ✅ Rate Limiting 请求限流
- ✅ 环境变量敏感信息隔离
- ✅ Docker 非 root 用户运行

## 监控和日志

查看容器日志：
```bash
docker logs -f math-notes-api
```

查看容器状态：
```bash
docker ps -f name=math-notes-api
```

健康检查：
```bash
curl http://localhost:3000/health
```

## 故障排查

### 容器无法启动
```bash
# 查看容器日志
docker logs math-notes-api

# 检查端口占用
netstat -tulpn | grep 3000

# 检查环境变量
docker exec math-notes-api env | grep DASHSCOPE
```

### API调用失败
1. 检查 API 密钥是否正确
2. 检查网络连接
3. 查看服务日志

### 镜像构建失败
```bash
# 清理Docker缓存
docker system prune -a

# 重新构建
docker build --no-cache -t math-notes-api .
```

## 项目结构

```
server/
├── src/
│   ├── config/          # 配置文件
│   ├── controllers/     # 控制器
│   ├── middleware/      # 中间件
│   ├── routes/          # 路由
│   ├── services/        # 业务逻辑服务
│   └── index.js         # 应用入口
├── scripts/             # 部署脚本
├── .github/             # GitHub Actions配置
├── Dockerfile           # Docker镜像配置
├── docker-compose.yml   # Docker Compose配置
├── package.json         # 项目依赖
└── README.md           # 本文档
```

## 许可证

MIT

## 贡献

欢迎提交 Issue 和 Pull Request！