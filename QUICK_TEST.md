# JavaFX 跨平台项目快速测试指南

## 概述

本文档提供了快速测试 JavaFX 跨平台项目构建和发布功能的方法。

## 🚀 快速测试步骤

### 1. 本地构建测试

#### 测试基本编译
```bash
# 基本编译测试
mvn clean compile --file pom.xml

# 完整构建测试
mvn clean package --file pom.xml
```

#### 测试桌面版本构建
```bash
# Linux/macOS/Windows 桌面版本
mvn clean package --file pom.xml -Dgluonfx.target=host
```

#### 测试 Android 版本构建（需要 Android SDK）
```bash
# Android 版本（需要正确配置环境）
mvn clean package --file pom.xml -P android -Dgluonfx.target=android
```

### 2. GitHub Actions 测试

#### 测试 CI 构建
1. 推送代码到 main/master 分支
2. 查看 GitHub Actions 中的 "JavaFX CI/CD" 工作流
3. 确认所有平台构建成功

#### 测试发布流程
```bash
# 方法一：使用脚本
./scripts/release.sh --dry-run 1.0.0-test

# 方法二：创建测试标签
git tag v1.0.0-test
git push origin v1.0.0-test
```

### 3. 验证构建产物

#### 检查本地构建输出
```bash
# 查看构建输出目录
ls -la target/
ls -la target/gluonfx/

# 检查生成的可执行文件
find target/gluonfx -name "*" -type f | head -10
```

#### 检查 GitHub 发布
1. 访问 GitHub 仓库的 Releases 页面
2. 确认包含以下文件：
   - `javafx-app-linux-x64.tar.gz`
   - `javafx-app-windows-x64.zip`
   - `javafx-app-macos.tar.gz`
   - `javafx-app-android.apk`

## 🔧 故障排除

### 常见问题

#### 1. Windows 构建失败
- 确保使用正确的 PowerShell 命令语法
- 检查 Maven 命令格式：`mvn ... --file pom.xml`

#### 2. Android 构建失败
- 确保安装了 Android SDK
- 检查 `ANDROID_HOME` 环境变量
- 确保安装了 GraalVM

#### 3. 权限问题
- 检查 GitHub Token 权限
- 确保有 `contents: write` 权限

### 调试命令

#### 查看详细构建日志
```bash
mvn clean package --file pom.xml -Dgluonfx.target=host -X
```

#### 检查环境变量
```bash
# Linux/macOS
echo $JAVA_HOME
echo $ANDROID_HOME
echo $GRAALVM_HOME

# Windows
echo %JAVA_HOME%
echo %ANDROID_HOME%
echo %GRAALVM_HOME%
```

## 📋 测试检查清单

### 本地测试
- [ ] 基本编译通过
- [ ] 桌面版本构建成功
- [ ] 生成了可执行文件
- [ ] 可执行文件能正常运行

### CI/CD 测试
- [ ] 推送到主分支触发构建
- [ ] 所有平台构建成功
- [ ] 构建产物上传成功
- [ ] 发布流程正常工作

### 发布测试
- [ ] 标签推送触发发布
- [ ] 创建了 GitHub Release
- [ ] 所有平台文件都已上传
- [ ] Release Notes 内容正确

## 🎯 快速验证脚本

### Linux/macOS
```bash
#!/bin/bash
echo "=== JavaFX 项目快速测试 ==="

echo "1. 测试基本编译..."
mvn clean compile --file pom.xml

echo "2. 测试完整构建..."
mvn clean package --file pom.xml -Dgluonfx.target=host

echo "3. 检查构建输出..."
ls -la target/gluonfx/

echo "测试完成！"
```

### Windows
```batch
@echo off
echo === JavaFX 项目快速测试 ===

echo 1. 测试基本编译...
mvn clean compile --file pom.xml

echo 2. 测试完整构建...
mvn clean package --file pom.xml -Dgluonfx.target=host

echo 3. 检查构建输出...
dir target\gluonfx\

echo 测试完成！
```

## 📞 获取帮助

如果遇到问题：
1. 查看 GitHub Actions 日志
2. 检查 [CICD_README.md](CICD_README.md) 详细说明
3. 在 GitHub Issues 中提问
4. 查看 [RELEASE_GUIDE.md](RELEASE_GUIDE.md) 发布指南

---

**提示**: 建议在正式发布前先使用 `-test` 后缀的版本号进行测试。