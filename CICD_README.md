# JavaFX 跨平台应用 CI/CD 说明文档

## 概述

本项目配置了完整的 CI/CD 流水线，支持自动构建和发布 JavaFX 应用程序到多个平台，包括 Linux、Windows、macOS 和 Android。

## 工作流程文件

### 1. `ci.yml` - 持续集成
- **触发条件**: 推送到 `master`/`main` 分支、Pull Request
- **功能**: 代码检查、构建测试、生成构建产物
- **平台支持**: Linux、Windows、macOS、Android

### 2. `release.yml` - 发布流程
- **触发条件**: 推送版本标签（如 `v1.0.0`）或手动触发
- **功能**: 构建所有平台的可执行文件并自动创建 GitHub Release
- **产物**: 打包好的可执行文件，可直接下载使用

## 支持的平台

| 平台 | 架构 | 输出格式 | 说明 |
|------|------|----------|------|
| Linux | x64 | `.tar.gz` | 包含可执行文件和启动脚本 |
| Windows | x64 | `.zip` | 包含 `.exe` 文件和启动脚本 |
| macOS | ARM64/x64 | `.tar.gz` | 自动检测架构，包含可执行文件和启动脚本 |
| Android | ARM64 | `.apk` | 可直接安装的 Android 应用 |

## 如何发布新版本

### 方法一：使用 Git 标签（推荐）

1. 确保你的代码已经推送到主分支
2. 创建并推送版本标签：
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```
3. GitHub Actions 会自动构建所有平台的可执行文件
4. 构建完成后会自动创建 GitHub Release 并上传文件

### 方法二：手动触发

1. 在 GitHub 仓库中，点击 "Actions" 标签
2. 选择 "Release" 工作流
3. 点击 "Run workflow"
4. 输入版本号（如 `v1.0.0`）
5. 点击 "Run workflow" 按钮

## 版本号规范

建议使用语义化版本号：
- `v1.0.0` - 正式版本
- `v1.0.0-beta.1` - 测试版本
- `v1.0.0-alpha.1` - 预发布版本
- `v1.0.0-rc.1` - 候选版本

包含 `-`、`alpha`、`beta`、`rc` 的版本会被标记为预发布版本。

## 构建产物说明

### Linux (`javafx-app-linux-x64.tar.gz`)
```
linux/
├── javafx-cross-platform-starter    # 可执行文件
├── start.sh                         # 启动脚本
└── ...                              # 其他依赖文件
```

### Windows (`javafx-app-windows-x64.zip`)
```
windows/
├── javafx-cross-platform-starter.exe  # 可执行文件
├── start.bat                          # 启动脚本
└── ...                                 # 其他依赖文件
```

### macOS (`javafx-app-macos.tar.gz`)
```
macos/
├── javafx-cross-platform-starter    # 可执行文件
├── start.sh                         # 启动脚本
└── ...                              # 其他依赖文件
```

### Android (`javafx-app-android.apk`)
- 可直接在 Android 设备上安装的 APK 文件
- 要求 Android 7.0 (API level 24) 或更高版本

## 自定义配置

### 修改 Java 版本
在 `ci.yml` 和 `release.yml` 文件中修改环境变量：
```yaml
env:
  JAVA_VERSION: "21"  # 改为你需要的 Java 版本
  JAVA_DISTRIBUTION: "temurin"
```

### 添加更多平台
可以在工作流中添加其他平台的构建任务，例如：
- iOS (需要额外的证书配置)
- ARM64 Linux
- 其他架构

### 修改构建参数
在各个平台的构建步骤中，可以修改 Maven 构建参数：
```bash
mvn -B clean package -Dgluonfx.target=host -Dgluonfx.aot.enabled=true
```

## 环境要求

### 构建环境
- Java 21 (可配置)
- Maven 3.6+
- GraalVM (用于 Android 构建)
- Android SDK (用于 Android 构建)

### 运行环境
- **桌面平台**: 无额外要求（自包含可执行文件）
- **Android**: Android 7.0+ (API level 24)

## 故障排除

### 常见问题

1. **构建失败 - 找不到 GraalVM**
   - 确保 GraalVM 设置正确
   - 检查 `GRAALVM_HOME` 环境变量

2. **Android 构建失败**
   - 检查 Android SDK 配置
   - 确保 `ANDROID_HOME` 环境变量设置正确

3. **macOS 构建架构问题**
   - 工作流会自动检测可用的架构（ARM64 或 x64）
   - 如果需要特定架构，可以在构建参数中指定

4. **Release 创建失败**
   - 检查 GitHub Token 权限
   - 确保仓库有 `contents: write` 权限

### 调试方法

1. 查看 GitHub Actions 日志
2. 检查构建产物是否正确生成
3. 验证文件路径和权限设置

## 安全考虑

- 所有敏感信息都使用 GitHub Secrets 存储
- 构建过程中不会暴露任何密钥或证书
- 发布权限严格控制在 tag 推送时触发

## 性能优化

- 使用 Maven 依赖缓存加速构建
- 并行构建多个平台
- 只在 tag 推送时执行完整的发布流程

## 自动化功能

- ✅ 自动构建多平台可执行文件
- ✅ 自动创建 GitHub Release
- ✅ 自动生成 Release Notes
- ✅ 自动上传构建产物
- ✅ 自动设置预发布标记
- ✅ 缓存依赖以提高构建速度

## 下一步计划

- [ ] 添加代码签名支持
- [ ] 支持 iOS 构建
- [ ] 添加自动化测试
- [ ] 集成安全扫描
- [ ] 添加性能基准测试

---

如有问题或建议，请在 GitHub Issues 中提出。