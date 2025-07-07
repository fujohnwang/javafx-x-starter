#!/bin/bash

# JavaFX Cross-Platform Release Script
# This script automates the release process for JavaFX applications

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
POM_FILE="$PROJECT_DIR/pom.xml"

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS] <version>"
    echo ""
    echo "Options:"
    echo "  -h, --help     Show this help message"
    echo "  -d, --dry-run  Show what would be done without actually doing it"
    echo "  -f, --force    Force release even if working directory is not clean"
    echo "  -p, --push     Automatically push tags to remote repository"
    echo ""
    echo "Version format examples:"
    echo "  1.0.0          - Release version"
    echo "  1.0.0-beta.1   - Beta version"
    echo "  1.0.0-alpha.1  - Alpha version"
    echo "  1.0.0-rc.1     - Release candidate"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0                    # Create release v1.0.0"
    echo "  $0 --dry-run 1.0.0         # Show what would be done"
    echo "  $0 --push 1.0.0            # Create and push release"
    echo "  $0 1.0.0-beta.1            # Create beta release"
}

# Function to check if git working directory is clean
check_git_status() {
    if [ -n "$(git status --porcelain)" ]; then
        print_error "Working directory is not clean. Please commit or stash your changes."
        git status --short
        if [ "$FORCE" != "true" ]; then
            exit 1
        else
            print_warning "Forcing release with uncommitted changes."
        fi
    fi
}

# Function to validate version format
validate_version() {
    local version=$1
    if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9]+(\.[0-9]+)?)?$ ]]; then
        print_error "Invalid version format: $version"
        print_error "Expected format: X.Y.Z or X.Y.Z-suffix.N"
        exit 1
    fi
}

# Function to check if tag already exists
check_tag_exists() {
    local tag=$1
    if git tag -l | grep -q "^$tag$"; then
        print_error "Tag $tag already exists. Please use a different version."
        exit 1
    fi
}

# Function to update version in pom.xml
update_pom_version() {
    local version=$1
    local current_version

    if [ ! -f "$POM_FILE" ]; then
        print_error "pom.xml not found at $POM_FILE"
        exit 1
    fi

    current_version=$(grep -m1 "<version>" "$POM_FILE" | sed 's/.*<version>\(.*\)<\/version>.*/\1/')
    print_status "Current version: $current_version"
    print_status "New version: $version"

    if [ "$DRY_RUN" = "true" ]; then
        print_status "DRY RUN: Would update version in pom.xml"
        return
    fi

    # Create backup
    cp "$POM_FILE" "$POM_FILE.backup"

    # Update version (first occurrence only - project version)
    sed -i.tmp "0,/<version>/{s/<version>.*<\/version>/<version>$version<\/version>/}" "$POM_FILE"
    rm "$POM_FILE.tmp"

    print_success "Updated version in pom.xml"
}

# Function to create git tag
create_git_tag() {
    local version=$1
    local tag="v$version"

    if [ "$DRY_RUN" = "true" ]; then
        print_status "DRY RUN: Would create git tag $tag"
        return
    fi

    # Add updated pom.xml to git
    git add "$POM_FILE"
    git commit -m "Bump version to $version"

    # Create annotated tag
    git tag -a "$tag" -m "Release version $version"

    print_success "Created git tag $tag"
}

# Function to push changes and tags
push_to_remote() {
    local version=$1
    local tag="v$version"

    if [ "$DRY_RUN" = "true" ]; then
        print_status "DRY RUN: Would push commits and tag $tag to remote"
        return
    fi

    # Push commits
    git push origin

    # Push tags
    git push origin "$tag"

    print_success "Pushed commits and tag $tag to remote"
}

# Function to get current git branch
get_current_branch() {
    git rev-parse --abbrev-ref HEAD
}

# Function to check if we're on main/master branch
check_main_branch() {
    local current_branch
    current_branch=$(get_current_branch)

    if [[ "$current_branch" != "main" && "$current_branch" != "master" ]]; then
        print_warning "You are not on main/master branch (current: $current_branch)"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Release cancelled."
            exit 1
        fi
    fi
}

# Function to show release summary
show_release_summary() {
    local version=$1
    local tag="v$version"

    echo ""
    echo "==================== RELEASE SUMMARY ===================="
    echo "Version: $version"
    echo "Tag: $tag"
    echo "Branch: $(get_current_branch)"
    echo "Repository: $(git config --get remote.origin.url)"
    echo ""

    if [[ $version =~ -(alpha|beta|rc) ]]; then
        echo "🔶 This is a PRE-RELEASE version"
    else
        echo "🔷 This is a STABLE release version"
    fi

    echo ""
    echo "Next steps:"
    echo "1. GitHub Actions will automatically build all platforms"
    echo "2. A new release will be created on GitHub"
    echo "3. Build artifacts will be attached to the release"
    echo ""
    echo "Monitor the build progress at:"
    echo "https://github.com/$(git config --get remote.origin.url | sed 's/.*github.com[:/]\(.*\)\.git.*/\1/')/actions"
    echo "=========================================================="
}

# Function to restore pom.xml from backup
restore_pom_backup() {
    if [ -f "$POM_FILE.backup" ]; then
        mv "$POM_FILE.backup" "$POM_FILE"
        print_status "Restored pom.xml from backup"
    fi
}

# Trap to cleanup on exit
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ] && [ -f "$POM_FILE.backup" ]; then
        print_error "Release failed. Restoring pom.xml backup."
        restore_pom_backup
    fi
    exit $exit_code
}

trap cleanup EXIT

# Parse command line arguments
DRY_RUN=false
FORCE=false
PUSH=false
VERSION=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_usage
            exit 0
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -f|--force)
            FORCE=true
            shift
            ;;
        -p|--push)
            PUSH=true
            shift
            ;;
        -*)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
        *)
            if [ -z "$VERSION" ]; then
                VERSION=$1
            else
                print_error "Multiple versions specified"
                show_usage
                exit 1
            fi
            shift
            ;;
    esac
done

# Check if version is provided
if [ -z "$VERSION" ]; then
    print_error "Version number is required"
    show_usage
    exit 1
fi

# Main execution
print_status "Starting release process for version $VERSION"

# Change to project directory
cd "$PROJECT_DIR"

# Validate inputs
validate_version "$VERSION"
check_tag_exists "v$VERSION"

# Check git status
check_git_status

# Check if we're on main branch
check_main_branch

# Confirm release
if [ "$DRY_RUN" != "true" ]; then
    echo ""
    print_warning "You are about to create a release for version $VERSION"
    read -p "Are you sure you want to continue? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_error "Release cancelled."
        exit 1
    fi
fi

# Execute release steps
print_status "Updating version in pom.xml..."
update_pom_version "$VERSION"

print_status "Creating git tag..."
create_git_tag "$VERSION"

if [ "$PUSH" = "true" ]; then
    print_status "Pushing to remote repository..."
    push_to_remote "$VERSION"
fi

# Clean up backup
if [ -f "$POM_FILE.backup" ]; then
    rm "$POM_FILE.backup"
fi

# Show summary
show_release_summary "$VERSION"

if [ "$DRY_RUN" = "true" ]; then
    print_success "DRY RUN completed. No actual changes were made."
else
    print_success "Release $VERSION created successfully!"
    if [ "$PUSH" != "true" ]; then
        print_warning "Don't forget to push your changes and tags:"
        echo "  git push origin"
        echo "  git push origin v$VERSION"
    fi
fi
