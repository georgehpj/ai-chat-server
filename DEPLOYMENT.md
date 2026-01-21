# 部署文档 - 阿里云 ECS 自动化部署指南

本文档详细介绍如何将 Math Notes API 服务部署到阿里云 ECS 服务器。

## 目录

1. [前置准备](#前置准备)
2. [ECS 服务器配置](#ecs-服务器配置)
3. [部署方式](#部署方式)
4. [自动化部署流程](#自动化部署流程)
5. [监控和维护](#监控和维护)
6. [故障排查](#故障排查)

## 前置准备

### 1. 阿里云资源准备

- ✅ 阿里云 ECS 实例（推荐配置：2核4G，Ubuntu 20.04 或 CentOS 7+）
- ✅ 阿里云百炼 API Key（获取地址：https://help.aliyun.com/zh/model-studio/get-api-key）
- ✅ 安全组规则：开放 3000 端口（HTTP）
- ✅ 公网 IP 或弹性公网 IP（EIP）

### 2. 本地环境准备

- Git 客户端
- SSH 客户端
- Docker（本地测试用，可选）

### 3. 获取 API Key

1. 登录阿里云控制台
2. 进入「模型服务灵积DashScope」
3. 创建 API Key
4. 记录 API Key（格式：`sk-xxx`）

## ECS 服务器配置

### 步骤 1：连接到 ECS 服务器

```bash
ssh root@your-ecs-ip
# 或
ssh your-username@your-ecs-ip
```

### 步骤 2：运行服务器初始化脚本

```bash
# 下载初始化脚本（或手动上传）
curl -O https://raw.githubusercontent.com/your-repo/math_notes/main/server/scripts/setup-server.sh

# 或从项目目录上传脚本
scp server/scripts/setup-server.sh root@your-ecs-ip:/tmp/

# 执行初始化
bash /tmp/setup-server.sh
# 或在项目目录中：bash scripts/setup-server.sh
```

初始化脚本会自动安装：
- Docker
- Docker Compose
- Git
- Node.js（可选）
- 配置防火墙

### 步骤 3：配置安全组

在阿里云控制台配置 ECS 安全组：

| 方向 | 协议 | 端口 | 授权对象 | 说明 |
|------|------|------|----------|------|
| 入方向 | TCP | 22 | 0.0.0.0/0 | SSH（建议限制来源IP） |
| 入方向 | TCP | 3000 | 0.0.0.0/0 | API 服务端口 |

### 步骤 4：创建应用目录

```bash
mkdir -p /opt/math-notes-api
cd /opt/math-notes-api
```

## 部署方式

### 方式一：手动部署（推荐首次部署）

#### 1. 克隆代码

```bash
cd /opt/math-notes-api
git clone https://github.com/your-username/your-repo.git .
# 或使用 SSH
git clone git@github.com:your-username/your-repo.git .
```

#### 2. 配置环境变量

```bash
cat > .env << EOF
DASHSCOPE_API_KEY=sk-your-api-key-here
DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
NODE_ENV=production
PORT=3000
VISION_MODEL=qwen3-vl-plus
CORS_ORIGINS=*
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
EOF

# 设置权限
chmod 600 .env
```

#### 3. 执行部署脚本

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh production
```

部署脚本会自动：
- 构建 Docker 镜像
- 停止旧容器
- 启动新容器
- 执行健康检查

#### 4. 验证部署

```bash
# 检查容器状态
docker ps | grep math-notes-api

# 查看日志
docker logs -f math-notes-api

# 健康检查
curl http://localhost:3000/health
```

### 方式二：Docker Compose 部署

#### 1. 配置环境变量

```bash
cd /opt/math-notes-api

# 方式 A：使用 .env 文件（推荐）
cat > .env << EOF
DASHSCOPE_API_KEY=sk-your-api-key-here
DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
NODE_ENV=production
VISION_MODEL=qwen3-vl-plus
CORS_ORIGINS=*
EOF

# 方式 B：使用环境变量
export DASHSCOPE_API_KEY=sk-your-api-key-here
export DASHSCOPE_BASE_URL=https://dashscope.aliyuncs.com/compatible-mode/v1
```

#### 2. 启动服务

```bash
docker-compose up -d
```

#### 3. 查看状态

```bash
# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down

# 重启服务
docker-compose restart
```

### 方式三：GitHub Actions 自动化部署

#### 1. 配置 GitHub Secrets

在 GitHub 仓库中进入 `Settings` → `Secrets and variables` → `Actions`，添加以下 Secrets：

| Secret 名称 | 说明 | 示例值 |
|------------|------|--------|
| `ECS_HOST` | ECS 公网 IP | `123.456.789.0` |
| `ECS_USER` | SSH 用户名 | `root` |
| `ECS_SSH_KEY` | SSH 私钥 | 见下方说明 |
| `ECS_PORT` | SSH 端口 | `22` |
| `DASHSCOPE_API_KEY` | API 密钥 | `sk-xxx` |
| `DASHSCOPE_BASE_URL` | API 地址（可选） | `https://dashscope.aliyuncs.com/compatible-mode/v1` |
| `VISION_MODEL` | 模型名称（可选） | `qwen3-vl-plus` |
| `CORS_ORIGINS` | CORS 配置（可选） | `*` |

#### 2. 生成 SSH 密钥对

```bash
# 在本地生成 SSH 密钥对
ssh-keygen -t rsa -b 4096 -C "github-actions" -f ~/.ssh/github_actions_ecs

# 将公钥添加到 ECS 服务器
ssh-copy-id -i ~/.ssh/github_actions_ecs.pub root@your-ecs-ip

# 将私钥内容添加到 GitHub Secrets
cat ~/.ssh/github_actions_ecs
# 复制输出内容到 GitHub Secrets 的 ECS_SSH_KEY
```

#### 3. 配置工作流文件

工作流文件已创建在 `.github/workflows/deploy.yml`，无需修改（除非需要自定义）。

#### 4. 触发部署

推送代码到 `main` 或 `master` 分支会自动触发部署：

```bash
git add .
git commit -m "Update code"
git push origin main
```

#### 5. 查看部署状态

在 GitHub 仓库的 `Actions` 标签页查看部署进度和日志。

## 自动化部署流程

### GitHub Actions 工作流说明

```yaml
触发条件：
- 推送到 main/master 分支
- 手动触发（workflow_dispatch）

部署步骤：
1. Checkout 代码
2. 构建 Docker 镜像
3. SSH 连接到 ECS
4. 拉取最新代码
5. 构建并启动容器
6. 健康检查
```

### 部署流程图

```
本地开发
    ↓
Git Push → GitHub
    ↓
GitHub Actions 触发
    ↓
构建 Docker 镜像
    ↓
SSH 连接 ECS
    ↓
拉取最新代码
    ↓
构建并启动容器
    ↓
健康检查
    ↓
部署完成 ✅
```

### 自定义部署脚本

如果需要自定义部署流程，可以修改 `scripts/deploy.sh`：

```bash
#!/bin/bash
# 添加自定义步骤
# 例如：备份数据库、运行迁移等
```

## 监控和维护

### 查看服务状态

```bash
# 容器状态
docker ps -a | grep math-notes-api

# 资源使用情况
docker stats math-notes-api

# 服务健康状态
curl http://localhost:3000/health
```

### 查看日志

```bash
# 实时日志
docker logs -f math-notes-api

# 最近 100 行日志
docker logs --tail 100 math-notes-api

# 带时间戳的日志
docker logs -f -t math-notes-api
```

### 更新服务

#### 手动更新

```bash
cd /opt/math-notes-api
git pull
./scripts/deploy.sh production
```

#### 自动更新（GitHub Actions）

```bash
# 只需推送代码即可
git push origin main
```

### 回滚版本

```bash
# 查看历史镜像
docker images | grep math-notes-api

# 回滚到指定版本
docker stop math-notes-api
docker rm math-notes-api
docker run -d \
  --name math-notes-api \
  --restart unless-stopped \
  -p 3000:3000 \
  -e DASHSCOPE_API_KEY="${DASHSCOPE_API_KEY}" \
  math-notes-api:previous-version-tag
```

### 清理资源

```bash
# 清理未使用的镜像
docker image prune -a

# 清理未使用的容器
docker container prune

# 清理所有未使用的资源
docker system prune -a
```

## 故障排查

### 问题 1：容器无法启动

**症状**：`docker ps` 看不到容器运行

**排查步骤**：

```bash
# 1. 查看容器日志
docker logs math-notes-api

# 2. 检查端口占用
netstat -tulpn | grep 3000
# 或
lsof -i :3000

# 3. 检查环境变量
docker exec math-notes-api env | grep DASHSCOPE

# 4. 手动启动容器查看错误
docker run --rm \
  -e DASHSCOPE_API_KEY="test" \
  math-notes-api:latest
```

**常见原因**：
- API Key 未配置或格式错误
- 端口被占用
- 内存不足
- 镜像构建失败

### 问题 2：API 调用失败

**症状**：接口返回错误

**排查步骤**：

```bash
# 1. 检查服务是否运行
curl http://localhost:3000/health

# 2. 查看应用日志
docker logs -f math-notes-api | grep -i error

# 3. 测试 API 连接
curl -X POST http://localhost:3000/api/vision/analyze \
  -H "Content-Type: application/json" \
  -d '{"image":"https://example.com/test.jpg","prompt":"test"}'

# 4. 检查网络连接
docker exec math-notes-api ping dashscope.aliyuncs.com
```

**常见原因**：
- API Key 无效或过期
- 网络连接问题
- 请求格式错误
- 模型服务异常

### 问题 3：GitHub Actions 部署失败

**症状**：Actions 显示失败状态

**排查步骤**：

1. **检查 Secrets 配置**
   - 进入 GitHub 仓库 Settings → Secrets
   - 确认所有必需的 Secrets 已配置

2. **检查 SSH 连接**
   ```bash
   # 在本地测试 SSH 连接
   ssh -i ~/.ssh/github_actions_ecs root@your-ecs-ip
   ```

3. **查看 Actions 日志**
   - 在 GitHub Actions 页面查看详细错误日志
   - 检查每个步骤的输出

4. **检查服务器磁盘空间**
   ```bash
   df -h
   ```

### 问题 4：服务响应慢

**排查步骤**：

```bash
# 1. 检查资源使用
docker stats math-notes-api

# 2. 检查系统负载
top
htop

# 3. 检查网络延迟
ping dashscope.aliyuncs.com

# 4. 查看请求处理时间
docker logs math-notes-api | grep "ms"
```

**优化建议**：
- 增加 ECS 实例配置（CPU/内存）
- 使用 CDN 加速图片传输
- 启用请求缓存（如需要）

### 问题 5：镜像构建失败

**排查步骤**：

```bash
# 1. 查看构建日志
docker build -t math-notes-api . --progress=plain

# 2. 检查 Dockerfile 语法
cat Dockerfile

# 3. 清理 Docker 缓存
docker system prune -a
docker build --no-cache -t math-notes-api .
```

## 安全建议

1. **API Key 安全**
   - ✅ 使用环境变量存储，不要硬编码
   - ✅ 定期轮换 API Key
   - ✅ 限制 API Key 权限范围

2. **服务器安全**
   - ✅ 使用 SSH 密钥而非密码
   - ✅ 定期更新系统补丁
   - ✅ 配置防火墙规则
   - ✅ 使用非 root 用户运行容器（已在 Dockerfile 中配置）

3. **网络安全**
   - ✅ 配置 HTTPS（使用 Nginx 反向代理）
   - ✅ 限制 CORS 来源
   - ✅ 启用 Rate Limiting

4. **监控告警**
   - ✅ 配置日志监控
   - ✅ 设置资源使用告警
   - ✅ 监控 API 调用异常

## 常见问题 FAQ

### Q: 如何查看 API 调用统计？

A: 查看容器日志或使用日志分析工具：
```bash
docker logs math-notes-api | grep "POST" | wc -l
```

### Q: 如何修改端口？

A: 修改环境变量 `PORT` 和 Docker 端口映射：
```bash
# .env 文件
PORT=8080

# docker run
-p 8080:3000
```

### Q: 支持多实例部署吗？

A: 可以，但需要：
- 使用负载均衡器（如 Nginx）
- 配置共享状态（如需要）
- 使用容器编排工具（Kubernetes、Docker Swarm）

### Q: 如何备份数据？

A: 如果使用数据库，需要配置数据库备份。当前服务为无状态服务，主要备份代码和配置：
```bash
# 备份代码
tar -czf backup-$(date +%Y%m%d).tar.gz /opt/math-notes-api

# 备份配置文件
cp .env .env.backup
```

## 联系和支持

如遇到问题，请：
1. 查看本文档的故障排查部分
2. 检查 GitHub Issues
3. 提交新的 Issue 并附上错误日志

---

**文档版本**：v1.0  
**最后更新**：2024