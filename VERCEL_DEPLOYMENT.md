# Vercel 部署指南

本指南将帮助你一步步将 Math Notes API 服务部署到 Vercel。

## 前置要求

- ✅ GitHub 账号
- ✅ Vercel 账号（免费注册：https://vercel.com）
- ✅ 项目代码已推送到 GitHub

## 步骤 1：注册 Vercel 账号

1. 访问 https://vercel.com
2. 点击 "Sign Up"
3. 选择 "Continue with GitHub"（推荐，可以自动连接仓库）
4. 完成注册流程

## 步骤 2：安装 Vercel CLI（可选，推荐）

虽然可以通过 Web 界面部署，但 CLI 工具更方便：

```bash
# 全局安装 Vercel CLI
npm install -g vercel

# 或者使用 npx（无需全局安装）
npx vercel
```

## 步骤 3：准备项目

确保项目结构正确：

```
server/
├── api/
│   └── index.js          # Vercel 入口文件（已创建）
├── src/                   # 源代码目录
├── package.json
├── vercel.json           # Vercel 配置（已创建）
└── .vercelignore         # 忽略文件（已创建）
```

## 步骤 4：配置环境变量

在 Vercel 部署前，需要配置以下环境变量：

### 必需的环境变量：

- `DASHSCOPE_API_KEY` - 阿里云百炼 API 密钥
- `DASHSCOPE_BASE_URL` - API 地址（可选，有默认值）

### 可选的环境变量：

- `NODE_ENV` - 环境模式（默认：production）
- `VISION_MODEL` - 视觉模型（默认：qwen3-vl-plus）
- `CORS_ORIGINS` - CORS 允许来源（逗号分隔）

## 步骤 5：部署到 Vercel

### 方式 A：通过 Vercel Web 界面部署（推荐新手）

1. **登录 Vercel Dashboard**
   - 访问 https://vercel.com/dashboard
   - 确保已登录

2. **导入项目**
   - 点击 "Add New..." → "Project"
   - 选择 "Import Git Repository"
   - 选择你的 GitHub 仓库（如果没有，先连接 GitHub）

3. **配置项目**
   - **Framework Preset**: 选择 "Other" 或 "Node.js"
   - **Root Directory**: 设置为 `server`（如果你的代码在 server 目录）
   - **Build Command**: 留空或填写 `npm install`
   - **Output Directory**: 留空
   - **Install Command**: `npm install`

4. **配置环境变量**
   - 在 "Environment Variables" 部分，添加以下变量：
   
   | 变量名 | 值 | 说明 |
   |--------|-----|------|
   | `DASHSCOPE_API_KEY` | `sk-xxx` | 你的 API 密钥 |
   | `DASHSCOPE_BASE_URL` | `https://dashscope.aliyuncs.com/compatible-mode/v1` | API 地址（可选） |
   | `VISION_MODEL` | `qwen3-vl-plus` | 模型名称（可选） |
   | `CORS_ORIGINS` | `*` 或具体域名 | CORS 配置（可选） |

5. **部署**
   - 点击 "Deploy" 按钮
   - 等待部署完成（通常 1-3 分钟）

6. **查看部署结果**
   - 部署成功后，Vercel 会提供一个 URL，例如：`https://your-project.vercel.app`
   - 访问 `https://your-project.vercel.app/health` 测试服务

### 方式 B：通过 Vercel CLI 部署

1. **登录 Vercel**
   ```bash
   cd server
   vercel login
   ```

2. **初始化项目**
   ```bash
   vercel
   ```
   
   按提示操作：
   - Set up and deploy? `Y`
   - Which scope? 选择你的账号
   - Link to existing project? `N`（首次部署）
   - Project name? 输入项目名称（如：math-notes-api）
   - Directory? `./`（如果已经在 server 目录）
   - Override settings? `N`

3. **配置环境变量**
   ```bash
   vercel env add DASHSCOPE_API_KEY
   # 输入你的 API 密钥
   # 选择环境：Production, Preview, Development（建议全部选择）
   
   vercel env add DASHSCOPE_BASE_URL
   # 输入：https://dashscope.aliyuncs.com/compatible-mode/v1
   
   # 可选环境变量
   vercel env add VISION_MODEL
   vercel env add CORS_ORIGINS
   ```

4. **部署到生产环境**
   ```bash
   vercel --prod
   ```

5. **查看部署结果**
   ```bash
   vercel ls          # 查看所有部署
   vercel inspect     # 查看最新部署详情
   ```

## 步骤 6：验证部署

部署完成后，测试以下端点：

```bash
# 健康检查
curl https://your-project.vercel.app/health

# 根路径
curl https://your-project.vercel.app/

# Vision API 健康检查
curl https://your-project.vercel.app/api/vision/health
```

## 步骤 7：配置自动部署（已自动配置）

Vercel 会自动：
- ✅ 监听 GitHub 仓库的 push 事件
- ✅ 自动触发新的部署
- ✅ 为每个分支创建 Preview 部署
- ✅ 为 main/master 分支创建 Production 部署

### 部署流程：

```
Git Push → GitHub
    ↓
Vercel 自动检测
    ↓
安装依赖（npm install）
    ↓
构建项目（如果有 build 命令）
    ↓
部署到边缘网络
    ↓
部署完成 ✅
```

## 步骤 8：自定义域名（可选）

1. 在 Vercel Dashboard 中进入项目
2. 点击 "Settings" → "Domains"
3. 添加你的自定义域名
4. 按照提示配置 DNS 记录
5. 等待 DNS 生效（通常几分钟到几小时）

## 故障排查

### 问题 1：部署失败 - Module not found

**解决方案**：
- 确保 `package.json` 中所有依赖都已列出
- 检查 `vercel.json` 配置是否正确
- 确保 `api/index.js` 文件存在

### 问题 2：环境变量未生效

**解决方案**：
- 在 Vercel Dashboard 中检查环境变量是否正确配置
- 确保环境变量作用域正确（Production/Preview/Development）
- 重新部署以应用新的环境变量

### 问题 3：函数执行超时

**解决方案**：
- Vercel 免费版函数最大执行时间为 10 秒
- Hobby 版为 60 秒
- 检查 `vercel.json` 中的 `maxDuration` 设置
- 优化 API 调用，减少处理时间

### 问题 4：CORS 错误

**解决方案**：
- 在环境变量中正确配置 `CORS_ORIGINS`
- 确保包含前端应用的域名
- 检查 `src/index.js` 中的 CORS 配置

### 问题 5：API 调用失败

**解决方案**：
- 检查 `DASHSCOPE_API_KEY` 是否正确
- 查看 Vercel 函数日志：`vercel logs`
- 或在 Dashboard 中查看 Function Logs

## 查看日志

### 方式 1：通过 CLI
```bash
vercel logs
vercel logs --follow  # 实时查看日志
```

### 方式 2：通过 Dashboard
1. 进入项目 Dashboard
2. 点击 "Deployments"
3. 选择具体的部署
4. 点击 "Functions" 标签
5. 查看函数日志

## Vercel 限制和注意事项

### 免费版限制：

- ⚠️ **函数执行时间**：10 秒（Serverless Functions）
- ⚠️ **带宽**：100GB/月
- ⚠️ **请求数**：无限
- ⚠️ **并发函数**：100
- ⚠️ **无状态**：每次请求都是独立的，无法保持长连接

### 注意事项：

1. **冷启动**：首次请求可能较慢（1-3 秒），因为需要启动函数
2. **状态管理**：不要在函数中保存状态，使用外部存储（数据库、Redis 等）
3. **文件系统**：只读，不能写入本地文件
4. **环境变量**：区分 Production、Preview、Development 环境

## 性能优化建议

1. **使用 Edge Functions**：对于简单逻辑，考虑使用 Edge Functions（更快的响应）
2. **缓存策略**：对频繁请求的数据进行缓存
3. **减少依赖**：只安装必需的依赖，减少 bundle 大小
4. **异步处理**：对于耗时操作，考虑异步处理或队列

## 升级到 Pro 版（可选）

如果需要更长的执行时间或更多功能：
- Pro 版：$20/月
- 函数执行时间：60 秒
- 更多带宽和资源

访问：https://vercel.com/pricing

## 相关命令

```bash
# 登录
vercel login

# 部署到生产环境
vercel --prod

# 部署到预览环境
vercel

# 查看部署列表
vercel ls

# 查看日志
vercel logs

# 查看项目信息
vercel inspect

# 删除部署
vercel remove <deployment-url>

# 查看环境变量
vercel env ls

# 删除环境变量
vercel env rm <key>
```

## 部署完成后的下一步

1. ✅ 测试所有 API 端点
2. ✅ 更新前端应用中的 API 地址
3. ✅ 配置自定义域名（可选）
4. ✅ 设置监控和告警（可选）
5. ✅ 配置备份和恢复策略

## 获取帮助

- Vercel 文档：https://vercel.com/docs
- Vercel Discord：https://vercel.com/discord
- GitHub Issues：在项目中提交问题

---

**部署成功！** 🎉

你的 API 现在可以通过 Vercel 的全球 CDN 访问，享受低延迟和高可用性！
