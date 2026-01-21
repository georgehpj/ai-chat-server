# Vercel 快速部署指南（5 分钟）

## 🚀 快速开始

### 步骤 1：注册 Vercel（1 分钟）

1. 访问 https://vercel.com
2. 点击 "Sign Up" → "Continue with GitHub"
3. 授权 GitHub 访问

### 步骤 2：部署项目（2 分钟）

1. 在 Vercel Dashboard 点击 "Add New..." → "Project"
2. 选择你的 GitHub 仓库
3. **配置项目**：
   - Framework Preset: `Other`
   - Root Directory: `server`（如果代码在 server 目录）
   - Build Command: 留空
   - Output Directory: 留空
   - Install Command: `npm install`

### 步骤 3：配置环境变量（1 分钟）

在 "Environment Variables" 部分添加：

```
DASHSCOPE_API_KEY = sk-你的API密钥
```

### 步骤 4：部署（1 分钟）

1. 点击 "Deploy"
2. 等待 1-3 分钟
3. 部署完成后，复制提供的 URL

### 步骤 5：测试

```bash
curl https://your-project.vercel.app/health
```

## ✅ 完成！

你的 API 现在已经部署到 Vercel！

**详细说明请查看：** `VERCEL_DEPLOYMENT.md`
