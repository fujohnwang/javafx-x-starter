@echo off
setlocal enabledelayedexpansion

:: JavaFX Cross-Platform Release Script for Windows
:: This script automates the release process for JavaFX applications

:: Script configuration
set "SCRIPT_DIR=%~dp0"
set "PROJECT_DIR=%SCRIPT_DIR%.."
set "POM_FILE=%PROJECT_DIR%\pom.xml"

:: Initialize variables
set "DRY_RUN=false"
set "FORCE=false"
set "PUSH=false"
set "VERSION="
set "SHOW_HELP=false"

:: Parse command line arguments
:parse_args
if "%~1"=="" goto :args_done
if "%~1"=="-h" set "SHOW_HELP=true" & shift & goto :parse_args
if "%~1"=="--help" set "SHOW_HELP=true" & shift & goto :parse_args
if "%~1"=="-d" set "DRY_RUN=true" & shift & goto :parse_args
if "%~1"=="--dry-run" set "DRY_RUN=true" & shift & goto :parse_args
if "%~1"=="-f" set "FORCE=true" & shift & goto :parse_args
if "%~1"=="--force" set "FORCE=true" & shift & goto :parse_args
if "%~1"=="-p" set "PUSH=true" & shift & goto :parse_args
if "%~1"=="--push" set "PUSH=true" & shift & goto :parse_args
if "%~1" neq "" (
    if "!VERSION!"=="" (
        set "VERSION=%~1"
    ) else (
        call :print_error "Multiple versions specified"
        goto :show_usage_and_exit
    )
)
shift
goto :parse_args

:args_done

:: Show help if requested
if "%SHOW_HELP%"=="true" goto :show_usage_and_exit

:: Check if version is provided
if "%VERSION%"=="" (
    call :print_error "Version number is required"
    goto :show_usage_and_exit
)

:: Main execution
call :print_status "Starting release process for version %VERSION%"

:: Change to project directory
cd /d "%PROJECT_DIR%"

:: Validate inputs
call :validate_version "%VERSION%"
if errorlevel 1 exit /b 1

call :check_tag_exists "v%VERSION%"
if errorlevel 1 exit /b 1

:: Check git status
call :check_git_status
if errorlevel 1 exit /b 1

:: Check if we're on main branch
call :check_main_branch
if errorlevel 1 exit /b 1

:: Confirm release
if "%DRY_RUN%" neq "true" (
    echo.
    call :print_warning "You are about to create a release for version %VERSION%"
    set /p "CONFIRM=Are you sure you want to continue? (y/N): "
    if /i "!CONFIRM!" neq "y" (
        call :print_error "Release cancelled."
        exit /b 1
    )
)

:: Execute release steps
call :print_status "Updating version in pom.xml..."
call :update_pom_version "%VERSION%"
if errorlevel 1 exit /b 1

call :print_status "Creating git tag..."
call :create_git_tag "%VERSION%"
if errorlevel 1 exit /b 1

if "%PUSH%"=="true" (
    call :print_status "Pushing to remote repository..."
    call :push_to_remote "%VERSION%"
    if errorlevel 1 exit /b 1
)

:: Clean up backup
if exist "%POM_FILE%.backup" del "%POM_FILE%.backup"

:: Show summary
call :show_release_summary "%VERSION%"

if "%DRY_RUN%"=="true" (
    call :print_success "DRY RUN completed. No actual changes were made."
) else (
    call :print_success "Release %VERSION% created successfully!"
    if "%PUSH%" neq "true" (
        call :print_warning "Don't forget to push your changes and tags:"
        echo   git push origin
        echo   git push origin v%VERSION%
    )
)

exit /b 0

:: Function to show usage
:show_usage
echo Usage: %~nx0 [OPTIONS] ^<version^>
echo.
echo Options:
echo   -h, --help     Show this help message
echo   -d, --dry-run  Show what would be done without actually doing it
echo   -f, --force    Force release even if working directory is not clean
echo   -p, --push     Automatically push tags to remote repository
echo.
echo Version format examples:
echo   1.0.0          - Release version
echo   1.0.0-beta.1   - Beta version
echo   1.0.0-alpha.1  - Alpha version
echo   1.0.0-rc.1     - Release candidate
echo.
echo Examples:
echo   %~nx0 1.0.0                    # Create release v1.0.0
echo   %~nx0 --dry-run 1.0.0         # Show what would be done
echo   %~nx0 --push 1.0.0            # Create and push release
echo   %~nx0 1.0.0-beta.1            # Create beta release
goto :eof

:show_usage_and_exit
call :show_usage
exit /b 1

:: Function to print colored output
:print_status
echo [INFO] %~1
goto :eof

:print_success
echo [SUCCESS] %~1
goto :eof

:print_warning
echo [WARNING] %~1
goto :eof

:print_error
echo [ERROR] %~1
goto :eof

:: Function to check if git working directory is clean
:check_git_status
git status --porcelain > nul 2>&1
if errorlevel 1 (
    call :print_error "Git is not available or this is not a git repository"
    exit /b 1
)

for /f %%i in ('git status --porcelain') do (
    call :print_error "Working directory is not clean. Please commit or stash your changes."
    git status --short
    if "%FORCE%" neq "true" (
        exit /b 1
    ) else (
        call :print_warning "Forcing release with uncommitted changes."
    )
    goto :eof
)
goto :eof

:: Function to validate version format
:validate_version
set "ver=%~1"
echo %ver% | findstr /r /c:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$" > nul
if not errorlevel 1 goto :eof

echo %ver% | findstr /r /c:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*-[a-zA-Z0-9][a-zA-Z0-9]*$" > nul
if not errorlevel 1 goto :eof

echo %ver% | findstr /r /c:"^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*-[a-zA-Z0-9][a-zA-Z0-9]*\.[0-9][0-9]*$" > nul
if not errorlevel 1 goto :eof

call :print_error "Invalid version format: %ver%"
call :print_error "Expected format: X.Y.Z or X.Y.Z-suffix.N"
exit /b 1

:: Function to check if tag already exists
:check_tag_exists
set "tag=%~1"
git tag -l | findstr /c:"%tag%" > nul
if not errorlevel 1 (
    call :print_error "Tag %tag% already exists. Please use a different version."
    exit /b 1
)
goto :eof

:: Function to update version in pom.xml
:update_pom_version
set "version=%~1"

if not exist "%POM_FILE%" (
    call :print_error "pom.xml not found at %POM_FILE%"
    exit /b 1
)

:: Get current version
for /f "tokens=2 delims=<>" %%a in ('findstr /c:"<version>" "%POM_FILE%"') do (
    set "current_version=%%a"
    goto :found_version
)

:found_version
call :print_status "Current version: %current_version%"
call :print_status "New version: %version%"

if "%DRY_RUN%"=="true" (
    call :print_status "DRY RUN: Would update version in pom.xml"
    goto :eof
)

:: Create backup
copy "%POM_FILE%" "%POM_FILE%.backup" > nul

:: Update version using PowerShell for better XML handling
powershell -Command "& { $xml = [xml](Get-Content '%POM_FILE%'); $xml.project.version = '%version%'; $xml.Save('%POM_FILE%') }"

call :print_success "Updated version in pom.xml"
goto :eof

:: Function to create git tag
:create_git_tag
set "version=%~1"
set "tag=v%version%"

if "%DRY_RUN%"=="true" (
    call :print_status "DRY RUN: Would create git tag %tag%"
    goto :eof
)

:: Add updated pom.xml to git
git add "%POM_FILE%"
git commit -m "Bump version to %version%"

:: Create annotated tag
git tag -a "%tag%" -m "Release version %version%"

call :print_success "Created git tag %tag%"
goto :eof

:: Function to push changes and tags
:push_to_remote
set "version=%~1"
set "tag=v%version%"

if "%DRY_RUN%"=="true" (
    call :print_status "DRY RUN: Would push commits and tag %tag% to remote"
    goto :eof
)

:: Push commits
git push origin
if errorlevel 1 (
    call :print_error "Failed to push commits"
    exit /b 1
)

:: Push tags
git push origin "%tag%"
if errorlevel 1 (
    call :print_error "Failed to push tag %tag%"
    exit /b 1
)

call :print_success "Pushed commits and tag %tag% to remote"
goto :eof

:: Function to get current git branch
:get_current_branch
for /f %%i in ('git rev-parse --abbrev-ref HEAD') do set "current_branch=%%i"
goto :eof

:: Function to check if we're on main/master branch
:check_main_branch
call :get_current_branch

if "%current_branch%"=="main" goto :eof
if "%current_branch%"=="master" goto :eof

call :print_warning "You are not on main/master branch (current: %current_branch%)"
set /p "CONTINUE=Continue anyway? (y/N): "
if /i "%CONTINUE%" neq "y" (
    call :print_error "Release cancelled."
    exit /b 1
)
goto :eof

:: Function to show release summary
:show_release_summary
set "version=%~1"
set "tag=v%version%"

echo.
echo ====================RELEASE SUMMARY====================
echo Version: %version%
echo Tag: %tag%
call :get_current_branch
echo Branch: %current_branch%

for /f %%i in ('git config --get remote.origin.url') do set "repo_url=%%i"
echo Repository: %repo_url%
echo.

echo %version% | findstr /c:"-alpha" > nul
if not errorlevel 1 (
    echo 🔶 This is a PRE-RELEASE version
    goto :summary_continue
)

echo %version% | findstr /c:"-beta" > nul
if not errorlevel 1 (
    echo 🔶 This is a PRE-RELEASE version
    goto :summary_continue
)

echo %version% | findstr /c:"-rc" > nul
if not errorlevel 1 (
    echo 🔶 This is a PRE-RELEASE version
    goto :summary_continue
)

echo 🔷 This is a STABLE release version

:summary_continue
echo.
echo Next steps:
echo 1. GitHub Actions will automatically build all platforms
echo 2. A new release will be created on GitHub
echo 3. Build artifacts will be attached to the release
echo.
echo Monitor the build progress at:
echo https://github.com/YOUR_USERNAME/YOUR_REPO/actions
echo ========================================================
goto :eof

:: Function to restore pom.xml from backup
:restore_pom_backup
if exist "%POM_FILE%.backup" (
    move "%POM_FILE%.backup" "%POM_FILE%" > nul
    call :print_status "Restored pom.xml from backup"
)
goto :eof

:: Error handling
:error_handler
call :print_error "Release failed. Restoring pom.xml backup."
call :restore_pom_backup
exit /b 1
