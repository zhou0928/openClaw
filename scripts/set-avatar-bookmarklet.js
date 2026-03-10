/**
 * OpenClaw 用户头像/名称设置工具
 *
 * 使用方法：
 * 1. 打开 OpenClaw 控制界面 (http://localhost:9999)
 * 2. 按 F12 打开开发者工具 → Console
 * 3. 复制粘贴下面的代码并回车运行
 */

// ==================== 修改这里的配置 ====================
const MY_NAME = "小周"; // 你想显示的名称
const MY_AVATAR = "🧑‍💻"; // 头像：可以是 Emoji、图片URL 或 base64
// ======================================================

// 保存配置
localStorage.setItem(
  "openclaw.user.identity.v1",
  JSON.stringify({
    name: MY_NAME,
    avatar: MY_AVATAR,
  }),
);

console.log("✅ 已设置用户身份：");
console.log("   名称:", MY_NAME);
console.log("   头像:", MY_AVATAR);
console.log("🔄 请刷新页面查看效果");

// 自动刷新
setTimeout(() => window.location.reload(), 500);
