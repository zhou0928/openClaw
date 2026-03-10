/**
 * 设置 OpenClaw Control UI 用户头像和名称
 *
 * 使用方法：
 * 1. 打开 OpenClaw 控制界面 (http://localhost:9999)
 * 2. 按 F12 打开开发者工具
 * 3. 切换到 Console 标签
 * 4. 复制粘贴以下代码并运行
 *
 * 或者直接在浏览器控制台运行：
 */

// ===== 配置区域 - 修改这里的值 =====
const USER_CONFIG = {
  // 用户显示名称（例如：小周、Zhou 等）
  name: "小周",

  // 用户头像 - 支持以下几种格式：
  // 1. Emoji: "🧑‍💻" 或 "😎"
  // 2. 图片 URL: "https://example.com/avatar.png"
  // 3. Base64 图片: "data:image/png;base64,iVBORw0KGgo..."
  // 4. 留空或 null 则使用默认 "U"
  avatar: "🧑‍💻",
};

// ===== 以下代码自动保存配置 =====
(function setUserIdentity() {
  const USER_IDENTITY_KEY = "openclaw.user.identity.v1";

  const identity = {
    name: USER_CONFIG.name,
    avatar: USER_CONFIG.avatar,
  };

  localStorage.setItem(USER_IDENTITY_KEY, JSON.stringify(identity));
  console.log("✅ 用户身份已设置：", identity);
  console.log("🔄 刷新页面后生效");

  // 可选：立即刷新页面
  if (confirm("设置已保存！是否立即刷新页面查看效果？")) {
    window.location.reload();
  }
})();
