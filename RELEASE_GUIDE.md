# JavaFX 跨平台应用发布指南

## 快速发布流程

### 1. 准备发布
```bash
# 1. 确保所有更改已提交并推送到主分支
git add .
git commit -m "Prepare for release v1.0.0"
git push origin main

# 2. 创建并推送版本标签
git tag v1.0.0
git push origin v1.0.0
```

### 2. 自动构建和发布
推送标签后，GitHub Actions 会自动：
- 构建 Linux x64 可执行文件
- 构建 Windows x64 可执行文件  
- 构建 macOS 可执行文件
- 构建 Android APK
- 创建 GitHub Release
- 上传所有构建产物

### 3. 验证发布
1. 访问 GitHub 仓库的 [Releases](../../releases) 页面
2. 确认新版本已创建
3. 下载并测试各平台的可执行文件

## 详细发布步骤

### 步骤 1：版本准备
1. **更新版本号**
   ```xml
   <!-- 在 pom.xml 中更新版本 -->
   <version>1.0.0</version>
   ```

2. **更新文档**
   - 更新 README.md 中的版本信息
   - 更新 CHANGELOG.md（如果有）
   - 检查所有文档的准确性

3. **本地测试**
   ```bash
   # 测试本地构建
   mvn clean package
   
   # 测试桌面版本
   mvn javafx:run
   ```

### 步骤 2：创建发布标签
```bash
# 创建带注释的标签（推荐）
git tag -a v1.0.0 -m "Release version 1.0.0"

# 或创建轻量标签
git tag v1.0.0

# 推送标签到远程仓库
git push origin v1.0.0
```

### 步骤 3：监控构建过程
1. 访问 GitHub Actions 页面
2. 查看 "Release" 工作流的运行状态
3. 监控各平台的构建进度：
   - ✅ Linux 构建
   - ✅ Windows 构建
   - ✅ macOS 构建
   - ✅ Android 构建
   - ✅ 创建 Release

### 步骤 4：发布后验证
1. **检查 Release 页面**
   - 确认版本号正确
   - 确认描述信息完整
   - 确认所有平台的文件都已上传

2. **测试下载链接**
   - 下载每个平台的文件
   - 验证文件完整性
   - 测试基本功能

3. **更新发布说明**（如需要）
   - 编辑 Release 说明
   - 添加重要更新信息
   - 添加已知问题说明

## 版本号规范

### 语义化版本控制
- **主版本号 (Major)**: 不兼容的 API 修改
- **次版本号 (Minor)**: 向下兼容的功能性新增
- **修订号 (Patch)**: 向下兼容的问题修正

### 版本格式示例
```
v1.0.0          # 正式版本
v1.0.0-beta.1   # 测试版本
v1.0.0-alpha.1  # 预览版本
v1.0.0-rc.1     # 候选版本
```

### 预发布版本
包含以下关键词的版本会被标记为预发布：
- `alpha` - 内部测试版本
- `beta` - 公开测试版本
- `rc` - 发布候选版本
- 任何包含 `-` 的版本

## 手动发布流程

### 当自动发布失败时
1. **访问 GitHub Actions**
2. **选择 "Release" 工作流**
3. **点击 "Run workflow"**
4. **输入版本标签**（如 `v1.0.0`）
5. **点击 "Run workflow" 按钮**

### 本地构建发布文件
```bash
# Linux 构建
mvn clean package -Dgluonfx.target=host

# Windows 构建（在 Windows 机器上）
mvn clean package -Dgluonfx.target=host

# macOS 构建（在 macOS 机器上）
mvn clean package -Dgluonfx.target=host

# Android 构建
mvn clean package -P android -Dgluonfx.target=android
```

## 发布后任务

### 1. 通知用户
- 发送邮件通知
- 更新官方网站
- 发布社交媒体公告
- 更新文档站点

### 2. 监控反馈
- 关注 GitHub Issues
- 监控下载统计
- 收集用户反馈
- 跟踪错误报告

### 3. 后续维护
- 修复紧急问题
- 准备补丁版本
- 计划下一个版本

## 常见问题处理

### 构建失败
```bash
# 检查构建日志
# 常见问题：
# 1. 依赖问题 - 检查 pom.xml
# 2. 环境问题 - 检查 Java/Maven 版本
# 3. 权限问题 - 检查 GitHub Token
```

### 发布失败
```bash
# 删除错误的标签
git tag -d v1.0.0
git push origin --delete v1.0.0

# 重新创建标签
git tag v1.0.0
git push origin v1.0.0
```

### 文件缺失
- 检查构建日志中的错误信息
- 验证目标平台的构建配置
- 确认文件路径设置正确

## 最佳实践

### 发布前检查清单
- [ ] 所有测试通过
- [ ] 文档已更新
- [ ] 版本号已更新
- [ ] 变更日志已准备
- [ ] 本地构建成功

### 发布规划
1. **预发布测试**
   - 使用 `-beta` 或 `-rc` 版本
   - 邀请用户测试
   - 收集反馈意见

2. **正式发布**
   - 确保预发布版本稳定
   - 准备发布说明
   - 选择合适的发布时间

3. **后续支持**
   - 监控用户反馈
   - 快速响应问题
   - 准备补丁版本

### 安全考虑
- 不要在发布说明中包含敏感信息
- 确保所有依赖项都是最新的安全版本
- 定期更新构建环境

## 故障排除

### 权限问题
```yaml
# 确保 GitHub Token 有足够权限
permissions:
  contents: write
  packages: write
```

### 构建超时
- 检查构建配置
- 优化构建步骤
- 使用缓存加速构建

### 平台特定问题
- **Linux**: 检查依赖库
- **Windows**: 检查 .NET 运行时
- **macOS**: 检查代码签名
- **Android**: 检查 SDK 版本

## 联系支持

如遇到问题，请：
1. 检查 [GitHub Issues](../../issues)
2. 查看 [GitHub Discussions](../../discussions)
3. 提交新的 Issue 并附上详细信息

---

📝 **注意**: 本指南会随着项目发展不断更新，请定期查看最新版本。