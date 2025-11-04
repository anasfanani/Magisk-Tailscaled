#!/bin/bash
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
WEBUI_DIR="$PROJECT_ROOT/webui"
WEBROOT_DIR="$PROJECT_ROOT/webroot"
ANDROID_DIR="$SCRIPT_DIR"
ANDROID_SDK="${ANDROID_SDK:-$HOME/android-sdk}"
GRADLE_VERSION="8.2"
BUILD_TOOLS_VERSION="34.0.0"
PLATFORM_VERSION="34"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Java if needed
install_java() {
    if command_exists java; then
        log_info "Java already installed: $(java -version 2>&1 | head -1)"
        return 0
    fi
    
    log_warn "Java not found, installing OpenJDK 17..."
    if command_exists apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y openjdk-17-jdk
    elif command_exists yum; then
        sudo yum install -y java-17-openjdk-devel
    else
        log_error "Cannot install Java automatically. Please install JDK 17 manually."
    fi
    log_info "Java installed successfully"
}

# Install Gradle
install_gradle() {
    if [ -f "$ANDROID_DIR/gradle/bin/gradle" ]; then
        log_info "Gradle already installed"
        return 0
    fi
    
    log_warn "Gradle not found, downloading..."
    cd "$ANDROID_DIR"
    curl -L "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" -o gradle.zip
    unzip -q gradle.zip
    rm gradle.zip
    mv "gradle-${GRADLE_VERSION}" gradle
    log_info "Gradle installed successfully"
}

# Install Android SDK
install_android_sdk() {
    if [ -d "$ANDROID_SDK/cmdline-tools/latest" ]; then
        log_info "Android SDK already installed at $ANDROID_SDK"
        return 0
    fi
    
    log_warn "Android SDK not found, installing..."
    mkdir -p "$ANDROID_SDK/cmdline-tools"
    
    cd /tmp
    wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
    unzip -q commandlinetools-linux-11076708_latest.zip
    mv cmdline-tools "$ANDROID_SDK/cmdline-tools/latest"
    rm commandlinetools-linux-11076708_latest.zip
    
    log_info "Android SDK installed at $ANDROID_SDK"
}

# Accept SDK licenses and install build tools
setup_android_sdk() {
    export ANDROID_HOME="$ANDROID_SDK"
    
    if [ -d "$ANDROID_SDK/platforms/android-${PLATFORM_VERSION}" ]; then
        log_info "Android SDK components already installed"
        return 0
    fi
    
    log_warn "Installing Android SDK components..."
    yes | "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || true
    "$ANDROID_SDK/cmdline-tools/latest/bin/sdkmanager" \
        "platform-tools" \
        "platforms;android-${PLATFORM_VERSION}" \
        "build-tools;${BUILD_TOOLS_VERSION}" >/dev/null 2>&1
    
    log_info "Android SDK components installed"
}

# Create local.properties
create_local_properties() {
    local props_file="$ANDROID_DIR/local.properties"
    if [ ! -f "$props_file" ]; then
        echo "sdk.dir=$ANDROID_SDK" > "$props_file"
        log_info "Created local.properties"
    fi
}

# Build WebUI
build_webui() {
    log_info "Building WebUI..."
    cd "$WEBUI_DIR"
    
    if ! command_exists npm; then
        log_error "npm not found. Please install Node.js first."
    fi
    
    npm install
    npm run build
    log_info "WebUI built successfully"
}

# Build APK
build_apk() {
    log_info "Building APK..."
    cd "$ANDROID_DIR"
    export ANDROID_HOME="$ANDROID_SDK"
    
    # Use daemon for faster incremental builds
    ./gradlew assembleRelease # --no-daemon
    log_info "APK built successfully"
}

# Create or use existing keystore
setup_keystore() {
    local keystore="$ANDROID_DIR/debug.keystore"
    
    if [ -f "$keystore" ]; then
        log_info "Using existing keystore"
        return 0
    fi
    
    log_warn "Creating debug keystore..."
    keytool -genkey -v \
        -keystore "$keystore" \
        -alias androiddebugkey \
        -keyalg RSA \
        -keysize 2048 \
        -validity 10000 \
        -storepass android \
        -keypass android \
        -dname "CN=Android Debug,O=Android,C=US" >/dev/null 2>&1
    
    log_info "Keystore created"
}

# Sign APK
sign_apk() {
    log_info "Signing APK..."
    local unsigned_apk="$ANDROID_DIR/app/build/outputs/apk/release/app-release-unsigned.apk"
    local signed_apk="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
    local keystore="$ANDROID_DIR/debug.keystore"
    
    "$ANDROID_SDK/build-tools/${BUILD_TOOLS_VERSION}/apksigner" sign \
        --ks "$keystore" \
        --ks-pass pass:android \
        --key-pass pass:android \
        --out "$signed_apk" \
        "$unsigned_apk"
    
    log_info "APK signed successfully"
}

# Verify APK
verify_apk() {
    local signed_apk="$ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
    
    if [ ! -f "$signed_apk" ]; then
        log_error "APK not found at $signed_apk"
    fi
    
    log_info "APK Details:"
    ls -lh "$signed_apk"
    
    "$ANDROID_SDK/build-tools/${BUILD_TOOLS_VERSION}/aapt" dump badging "$signed_apk" | head -5
}

# Main build process
main() {
    log_info "Starting APK build process..."
    
    # Prerequisites
    install_java
    install_gradle
    install_android_sdk
    setup_android_sdk
    create_local_properties
    
    # Build
    build_webui
    build_apk
    
    # Sign
    setup_keystore
    sign_apk
    
    # Verify
    verify_apk
    
    echo ""
    log_info "✓ Build completed successfully!"
    log_info "APK: $ANDROID_DIR/app/build/outputs/apk/release/app-release.apk"
}

# Run main
main "$@"
