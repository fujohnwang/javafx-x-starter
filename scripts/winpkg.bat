@echo off
setlocal enabledelayedexpansion

@REM set JDK=%1
@REM 使用github actions workflow的环境变量定义传入JDK路径

@REM echo Java home = %JAVA_HOME%
@REM dir %JAVA_HOME%
@REM dir %JAVA_HOME%\bin

:: 前置逻辑：清理、构建和复制文件到 pkg 目录
:: 删除 pkg 目录（等同于 rm -rf pkg）
if exist pkg (
    rmdir /s /q pkg
)

:: 创建 pkg 目录（等同于 mkdir pkg）
mkdir pkg

:: 复制文件到 pkg 目录
copy target\*.jar pkg\
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to copy jar to pkg dir.
    exit /b %ERRORLEVEL%
)

copy fixtures\splash.png pkg\
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to copy splash.png.
    exit /b %ERRORLEVEL%
)

copy fixtures\goatman.ico pkg\
if %ERRORLEVEL% neq 0 (
    echo Error: Failed to copy icon.
    exit /b %ERRORLEVEL%
)

@REM copy LICENCE.TXT pkg\
@REM if %ERRORLEVEL% neq 0 (
@REM     echo Error: Failed to copy LICENCE.TXT.
@REM     exit /b %ERRORLEVEL%
@REM )

echo Files copied successfully to pkg directory.

:: jpackage 参数配置
set APP_NAME=javafx-app
set JAR_FILE=javafx-cross-platform-starter-1.0-SNAPSHOT-win.jar
set MAIN_JAR=pkg\%JAR_FILE%
set OUTPUT_DIR=dist\
set ICON_PATH=pkg\goatman.ico
set APP_VERSION=1.0.0
set VENDOR=KEEVOL
set DESCRIPTION="Fuqiang JavaFX Application"
set COPYRIGHT="Copyright © 2025 KEEVOL.cn"
set MAIN_CLASS=com.example.AppLauncher
set INSTALLER_NAME=%APP_NAME%-Installer
set JAVA_OPTIONS="--enable-native-access=ALL-UNNAMED"

:: 检查 JAR 文件是否存在
if not exist %MAIN_JAR% (
    echo Error: %MAIN_JAR% not found. Please check the copy step.
    exit /b 1
)
@REM fatjar to dist also
copy target\javafx*.jar dist\

:: 创建输出目录
if not exist %OUTPUT_DIR% (
    mkdir %OUTPUT_DIR%
)

:: 运行 jpackage 命令
echo Creating Windows installer...
"%JAVA_HOME%\bin\jpackage.exe" ^
  --type msi ^
  --input pkg ^
  --name %APP_NAME% ^
  --main-jar %JAR_FILE% ^
  --main-class %MAIN_CLASS% ^
  --dest %OUTPUT_DIR% ^
  --app-version %APP_VERSION% ^
  --vendor %VENDOR% ^
  --description %DESCRIPTION% ^
  --copyright %COPYRIGHT% ^
  --icon %ICON_PATH% ^
  --win-dir-chooser ^
  --win-shortcut ^
  --win-menu ^
  --java-options "!JAVA_OPTIONS!" ^
  --verbose

:: 检查 jpackage 是否成功
if %ERRORLEVEL% neq 0 (
    echo Error: jpackage failed with error code %ERRORLEVEL%.
    exit /b %ERRORLEVEL%
)

echo Installer created successfully at %OUTPUT_DIR%\%INSTALLER_NAME%.msi
endlocal