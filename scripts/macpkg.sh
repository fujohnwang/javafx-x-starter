#!/bin/bash

# 设置基本参数
WORKDIR=`pwd`
echo ${WORKDIR}

INPUT_DIR="${WORKDIR}/pkg"
OUTPUT_DIR="${WORKDIR}/dist"
APP_NAME="javafx-app"
JAR_FILE_NAME="javafx-cross-platform-starter-1.0-SNAPSHOT-mac.jar"
JAR_FILE="${INPUT_DIR}/${JAR_FILE_NAME}"
APP_VERSION="1.0.0"
MAIN_CLASS="com.example.AppLauncher"
VENDOR="KEEVOL"
DESCRIPTION="Fuqiang's JavaFX Application"
COPYRIGHT="Copyright © 2025 KEEVOL.cn"
JAVA_OPTIONS="--enable-native-access=ALL-UNNAMED"
ICON_PATH="fixtures/my_icon.icns"

# 删除旧的输出目录
if [ -d "$INPUT_DIR" ]; then
    rm -rf "$INPUT_DIR"
fi
if [ -d "$OUTPUT_DIR" ]; then
    rm -rf "$OUTPUT_DIR"
fi

# 创建输出目录
mkdir -p "$INPUT_DIR"
mkdir -p "$OUTPUT_DIR"


echo "copy jar from target to pkg dir..."
cp -Rv "${WORKDIR}"/target/*.jar "${INPUT_DIR}/"

# 检查 JAR 文件是否存在
if [ ! -f "$JAR_FILE" ]; then
    echo "Error: $JAR_FILE not found. Please run 'mvn package' first."
    exit 1
fi


# 运行 jpackage 命令
echo "Creating macOS DMG installer..."
"${JAVA_HOME}"/bin/jpackage \
  --type dmg \
  --input "./${INPUT_DIR}" \
  --name "$APP_NAME" \
  --main-jar "${JAR_FILE}" \
  --main-class "$MAIN_CLASS" \
  --dest "${OUTPUT_DIR}" \
  --app-version "$APP_VERSION" \
  --vendor "$VENDOR" \
  --description "$DESCRIPTION" \
  --copyright "$COPYRIGHT" \
  --icon "$ICON_PATH" \
  --mac-package-name "$APP_NAME" \
  --java-options "$JAVA_OPTIONS" \
  --verbose

# 检查 jpackage 是否成功
if [ $? -ne 0 ]; then
    echo "Error: jpackage failed."
    exit 1
fi

echo "Installer created successfully at ${OUTPUT_DIR}/$APP_NAME-$APP_VERSION.dmg"
ls -l "${OUTPUT_DIR}"