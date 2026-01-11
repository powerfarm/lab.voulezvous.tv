#!/bin/bash
# Install tools for VVTV LAB
set -euo pipefail

echo "🔧 Installing VVTV LAB dependencies..."

# Check if running as the lab user
if [ "$(whoami)" != "ubl-ops" ] && [ "$(whoami)" != "root" ]; then
    echo "⚠️  Run as ubl-ops or with sudo"
    exit 1
fi

# ============================================
# Homebrew
# ============================================
if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "✅ Homebrew already installed"
fi

# ============================================
# System tools
# ============================================
echo "📦 Installing system dependencies..."
brew install \
    ffmpeg \
    yt-dlp \
    jq \
    ripgrep \
    fd \
    git \
    curl \
    wget

# ============================================
# Ollama (LLM runtime)
# ============================================
if ! command -v ollama &> /dev/null; then
    echo "🤖 Installing Ollama..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "✅ Ollama already installed"
fi

# ============================================
# Rust toolchain
# ============================================
if ! command -v rustc &> /dev/null; then
    echo "🦀 Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
else
    echo "✅ Rust already installed"
fi

# ============================================
# Optional: MinIO (local S3 simulator)
# ============================================
if ! command -v minio &> /dev/null; then
    echo "🪣 Installing MinIO (optional)..."
    brew install minio/stable/minio
else
    echo "✅ MinIO already installed"
fi

echo "✅ Installation complete!"
echo ""
echo "Next steps:"
echo "  1. Run: ollama serve"
echo "  2. Load models: ollama pull phi3:mini"
echo "  3. Build VVTV: cd /path/to/voulezvous.tv && cargo build --release"
