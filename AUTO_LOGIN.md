# OpenClaw 自动登录功能

## ✨ 功能说明

为了实现每次启动服务时自动填写 Token，我们创建了一个自动登录页面。

## 🚀 使用方法

### 方法 1：通过启动脚本自动打开

```bash
# 首次部署
./scripts/docker-deploy.sh

# 或快速启动
./scripts/docker-start.sh
```

脚本会自动打开浏览器，访问 `auto-login.html`，自动设置 Token 并跳转到网关页面。

### 方法 2：手动打开自动登录页面

```bash
# 在浏览器中打开自动登录页面
open auto-login.html
```

或直接在浏览器地址栏输入：

```
file:///Users/xiaozhou/Desktop/openclaws/auto-login.html
```

## 🔧 工作原理

### 自动登录流程

```
1. 用户运行启动脚本
    ↓
2. 脚本自动打开 auto-login.html
    ↓
3. 自动登录页面执行 JavaScript：
   - 将 Token 写入 localStorage
   - 将 Gateway URL 写入 localStorage
    ↓
4. 页面自动跳转到网关页面
    ↓
5. 网关页面从 localStorage 读取 Token
    ↓
6. 自动完成认证，无需手动输入
```

### 存储位置

Token 和 Gateway URL 存储在浏览器的 `localStorage` 中：

```javascript
localStorage.setItem("openclaw_token", "my-fixed-openclaw-token-please-change-this-in-production");
localStorage.setItem("openclaw_gateway_url", "http://localhost:9999");
```

## 📋 自动登录页面内容

`auto-login.html` 文件包含：

1. **自动设置 Token**：将固定 Token 存储到浏览器
2. **自动跳转**：设置完成后自动跳转到网关页面
3. **错误处理**：如果设置失败，提供手动登录按钮
4. **美观界面**：包含加载动画和状态提示

## 🛠️ 自定义配置

如果您需要修改 Token 或网关地址，编辑 `auto-login.html` 文件：

```javascript
// 在 <script> 标签中找到这两行并修改
const TOKEN = "your-new-token-here";
const GATEWAY_URL = "http://localhost:9999";
```

### 直接使用 URL

您也可以直接在浏览器地址栏输入带 Token 的 URL：

```
http://localhost:9999/?token=my-fixed-openclaw-token-please-change-this-in-production
```

## ⚠️ 注意事项

1. **Token 持久性**
   - Token 存储在浏览器的 localStorage 中
   - 清除浏览器缓存或隐私模式下需要重新设置
   - 建议使用正常浏览器窗口（不是无痕模式）

2. **安全性**
   - 当前使用的是固定 Token，适合开发环境
   - 生产环境请使用更安全的认证方式
   - 不要将 `auto-login.html` 部署到公网

3. **跨浏览器**
   - 每个浏览器需要单独设置 Token
   - 不同浏览器的 localStorage 不互通

## 🔍 故障排查

### 问题：自动登录页面打开后没有跳转

**解决方案：**

1. 检查浏览器控制台是否有错误
2. 确保 `auto-login.html` 文件存在
3. 手动访问 `http://localhost:9999/` 并输入 Token

### 问题：跳转后仍需要输入 Token

**解决方案：**

1. 打开浏览器开发者工具（F12）
2. 在 Console 中输入：`localStorage.getItem('openclaw_token')`
3. 如果返回 `null`，说明 Token 未设置成功
4. 检查浏览器是否禁用了 localStorage

### 问题：清除缓存后需要重新输入

**这是正常行为**：

- localStorage 存储在浏览器本地
- 清除缓存会删除 localStorage 中的数据
- 解决方案：再次访问 `auto-login.html` 重新设置

## 📚 相关文档

- [Docker 配置状态](DOCKER_CONFIG_STATUS.md)
- [Token 修复指南](TOKEN_FIX_GUIDE.md)
- [Docker 部署指南](DOCKER_DEPLOY.md)
- [脚本使用指南](scripts/README.md)

## 🎉 总结

现在您可以：

1. ✅ 运行 `./scripts/docker-start.sh` 启动服务
2. ✅ 浏览器自动打开并自动填写 Token
3. ✅ 直接使用 OpenClaw，无需手动输入
4. ✅ 享受完全自动化的体验！

**提示：首次使用建议保存 `auto-login.html` 到书签，方便快速访问！** 🦞
