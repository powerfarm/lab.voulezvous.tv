#!/bin/bash
# Start MinIO for local S3 simulation
set -euo pipefail

MINIO_DATA_DIR="/var/lib/vvtv/minio"
MINIO_PORT=9000
MINIO_CONSOLE_PORT=9001

echo "🪣 Starting MinIO..."

# Create data directory
mkdir -p "$MINIO_DATA_DIR"

# Check if already running
if pgrep -f "minio server" > /dev/null; then
    echo "✅ MinIO already running"
    exit 0
fi

# Start MinIO in background
nohup minio server \
    --address ":$MINIO_PORT" \
    --console-address ":$MINIO_CONSOLE_PORT" \
    "$MINIO_DATA_DIR" \
    > /opt/vvtv/logs/minio.log 2>&1 &

# Wait for MinIO to be ready
MAX_RETRIES=30
RETRY_COUNT=0
while ! curl -s http://localhost:$MINIO_PORT/minio/health/live > /dev/null; do
    echo "⏳ Waiting for MinIO to start... ($RETRY_COUNT/$MAX_RETRIES)"
    sleep 2
    RETRY_COUNT=$((RETRY_COUNT + 1))
    if [ $RETRY_COUNT -ge $MAX_RETRIES ]; then
        echo "❌ MinIO failed to start"
        exit 1
    fi
done

echo "✅ MinIO started successfully"
echo ""
echo "Console: http://localhost:$MINIO_CONSOLE_PORT"
echo "Endpoint: http://localhost:$MINIO_PORT"
echo ""
echo "Default credentials:"
echo "  Access Key: minioadmin"
echo "  Secret Key: minioadmin"
