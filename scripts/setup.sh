#!/bin/bash
# VaaniSetu - Day 1 Setup Script
# Run this on your MacBook M2 Air
# Usage: chmod +x setup.sh && ./setup.sh

set -e

echo ""
echo "╔══════════════════════════════════════╗"
echo "║   VaaniSetu - வாணி சேது Setup       ║"
echo "║   Tamil AI Assistant                 ║"
echo "╚══════════════════════════════════════╝"
echo ""

# ── Step 1: Check Homebrew ────────────────────────────────────────────────────
echo "📦 Step 1: Checking Homebrew..."
if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "✅ Homebrew found"
fi

# ── Step 2: Install Ollama ────────────────────────────────────────────────────
echo ""
echo "🤖 Step 2: Installing Ollama..."
if ! command -v ollama &> /dev/null; then
    brew install ollama
    echo "✅ Ollama installed"
else
    echo "✅ Ollama already installed"
fi

# ── Step 3: Pull Gemma 4 model ────────────────────────────────────────────────
echo ""
echo "⬇️  Step 3: Pulling Gemma 4 model (this may take 5-10 mins)..."
echo "    Using gemma3:4b (2.5GB) - perfect for M2 Air"
echo "    For better quality later, run: ollama pull gemma3:12b"
ollama pull gemma3:4b
echo "✅ Gemma 4 model ready"

# ── Step 4: Python backend setup ─────────────────────────────────────────────
echo ""
echo "🐍 Step 4: Setting up Python backend..."
cd backend

if ! command -v python3 &> /dev/null; then
    brew install python3
fi

python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
echo "✅ Python backend ready"

# ── Step 5: Flutter setup ─────────────────────────────────────────────────────
echo ""
echo "📱 Step 5: Checking Flutter..."
if ! command -v flutter &> /dev/null; then
    echo "⚠️  Flutter not found!"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install/macos"
    echo "Then run this script again."
    exit 1
else
    echo "✅ Flutter found: $(flutter --version | head -1)"
fi

cd ../flutter_app
flutter pub get
echo "✅ Flutter dependencies installed"

# ── Done! ─────────────────────────────────────────────────────────────────────
echo ""
echo "╔══════════════════════════════════════╗"
echo "║   ✅ Setup Complete!                 ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "To START the app:"
echo ""
echo "  Terminal 1 (Start Ollama):"
echo "  $ ollama serve"
echo ""
echo "  Terminal 2 (Start Backend):"
echo "  $ cd backend && source venv/bin/activate && python main.py"
echo ""
echo "  Terminal 3 (Run Flutter):"
echo "  $ cd flutter_app && flutter run"
echo ""
echo "  Backend API docs: http://localhost:8000/docs"
echo ""
