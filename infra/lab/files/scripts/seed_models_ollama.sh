#!/bin/bash
# Seed Ollama models for VVTV
set -euo pipefail

MODELS=("$@")

if [ ${#MODELS[@]} -eq 0 ]; then
    echo "Usage: $0 <model1> <model2> ..."
    exit 1
fi

echo "🤖 Seeding Ollama models..."

# Wait for Ollama to be ready
MAX_RETRIES=30
RETRY_COUNT=0
while ! curl -s http://localhost:11434/api/tags > /dev/null; do
    echo "⏳ Waiting for Ollama to start... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "❌ Ollama failed to start"
        exit 1
    fi
done

echo "✅ Ollama is ready"

# Pull each model
for MODEL in "${MODELS[@]}"; do
    echo "📥 Pulling model: $MODEL"
    if ollama list | grep -q "^$MODEL"; then
        echo "✅ Model $MODEL already exists"
    else
        ollama pull "$MODEL"
        echo "✅ Model $MODEL pulled successfully"
    fi
done

echo ""
echo "✅ All models ready:"
ollama list

echo ""
echo "Test with:"
echo "  ollama run phi3:mini 'Hello, world!'"
