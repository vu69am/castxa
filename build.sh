#!/bin/bash
set -e

echo "==================================="
echo "CastX Build Script"
echo "==================================="

# Detect OS
OS=$(uname -s)
ARCH=$(uname -m)

echo "OS: $OS"
echo "Architecture: $ARCH"

# Install build dependencies based on OS
install_dependencies() {
    if [ "$OS" = "Linux" ]; then
        echo ""
        echo "Step 0: Installing Linux build dependencies..."
        
        # Check if apt-get is available (Ubuntu/Debian)
        if command -v apt-get &> /dev/null; then
            echo "Installing X11 and build tools via apt-get..."
            sudo apt-get update
            sudo apt-get install -y \
                build-essential \
                libx11-dev \
                libxtst-dev \
                libxinerama-dev \
                libxcursor-dev \
                pkg-config
            echo "✓ Linux dependencies installed"
        else
            echo "Warning: apt-get not found. Please install X11 development libraries manually."
            echo "  For Ubuntu/Debian: sudo apt-get install libx11-dev libxtst-dev libxinerama-dev"
            echo "  For Fedora: sudo dnf install libX11-devel libXtst-devel libXinerama-devel"
            echo "  For Arch: sudo pacman -S libx11 libxtst libxinerama"
        fi
    elif [ "$OS" = "Darwin" ]; then
        echo "Step 0: Installing macOS build dependencies..."
        if command -v brew &> /dev/null; then
            echo "Installing via Homebrew..."
            brew install pkg-config
            echo "✓ macOS dependencies installed"
        else
            echo "Warning: Homebrew not found. Please install Xcode Command Line Tools."
            echo "  Run: xcode-select --install"
        fi
    else
        echo "Warning: Unsupported OS: $OS"
    fi
}

# Check Go installation
check_go() {
    echo ""
    echo "Checking Go installation..."
    
    # Try to find the correct Go binary
    if [ -f "/usr/local/go/bin/go" ]; then
        GO_BIN="/usr/local/go/bin/go"
        echo "Found Go at: $GO_BIN"
    elif command -v go &> /dev/null; then
        GO_BIN="go"
    else
        echo "✗ Go is not installed!"
        echo "Please install Go 1.24.5 or later from https://golang.org/dl/"
        exit 1
    fi
    
    GO_VERSION=$($GO_BIN version | awk '{print $3}')
    echo "✓ Go version: $GO_VERSION"
}

# Main build process
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)

echo ""
install_dependencies
check_go

echo ""
echo "Step 1: Running go mod tidy..."
$GO_BIN mod tidy

echo ""
echo "Step 2: Creating bin directory..."
mkdir -p bin

echo ""
echo "Step 3: Building main binary..."
GO_BUILD_FLAGS="${GO_BUILD_FLAGS:-}"
$GO_BIN build $GO_BUILD_FLAGS -o bin/castx main.go

echo ""
echo "==================================="
echo "✓ Build completed successfully!"
echo "==================================="
ls -lh bin/castx

echo ""
echo "Binary location: $PROJECT_DIR/bin/castx"
echo "To run: ./bin/castx"