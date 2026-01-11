# VVTV Ledger Service

**Baseline verificável**: serviço HTTP que registra fatos canônicos em streams NDJSON.

## 🎯 Features

- ✅ POST `/facts` - Grava fato canônico (JSON✯Atomic + CID BLAKE3)
- ✅ GET `/facts/{cid}` - Busca fato por CID
- ✅ GET `/facts/stream/{stream}` - Lista fatos de um stream
- ✅ Streams separados: `plans`, `assets`, `queue`, `playout`, `policy`
- ✅ Métricas Prometheus: latência, contadores, erros
- ✅ Health check `/health`

## 🚀 Quick Start

### Build

```bash
cd apps/vvtv-ledger-svc
cargo build --release
```

### Run

```bash
# Com env vars
export VVTV_LEDGER_DIR=/var/lib/vvtv/ledger
export VVTV_LEDGER_BIND=0.0.0.0:8080
export RUST_LOG=info,vvtv_ledger_svc=debug

cargo run --release
```

### Docker (opcional)

```bash
docker build -t vvtv-ledger-svc .
docker run -p 8080:8080 \
  -v /var/lib/vvtv/ledger:/data \
  -e VVTV_LEDGER_DIR=/data \
  vvtv-ledger-svc
```

## 📝 API Examples

### Health check

```bash
curl http://localhost:8080/health
```

Response:
```json
{
  "status": "healthy",
  "service": "vvtv-ledger-svc",
  "version": "0.1.0"
}
```

### Create a PlanCreated fact

```bash
curl -X POST http://localhost:8080/facts \
  -H "Content-Type: application/json" \
  -d '{
    "type": "PlanCreated",
    "timestamp": "2026-01-10T20:00:00Z",
    "plan_id": "plan_001",
    "source": "youtube",
    "url": "https://example.com/video",
    "title": "Test Video",
    "duration_secs": 720,
    "tags": ["sensual", "hd"],
    "bucket": "sensual",
    "score": 0.85
  }'
```

Response:
```json
{
  "cid": "a1b2c3d4...",
  "stream": "plans",
  "canonical": "{...canonical JSON...}"
}
```

### Get fact by CID

```bash
curl http://localhost:8080/facts/a1b2c3d4...
```

Response headers include:
- `X-Content-CID`: Original CID
- `X-Content-Hash`: BLAKE3 hash for verification

### List facts in a stream

```bash
curl http://localhost:8080/facts/stream/plans
```

Response: Array of canonical JSON strings

### Metrics

```bash
curl http://localhost:8080/metrics
```

Key metrics:
- `ledger_append_duration_seconds` - Histogram de latência
- `facts_written_total{stream="..."}` - Contadores por stream
- `ledger_errors_total{error="..."}` - Erros

## 📊 Streams & Fact Types

| Stream   | Fact Types                                                                 |
|----------|---------------------------------------------------------------------------|
| plans    | PlanCreated, PlanScheduledForDownload, PlanArchived                       |
| assets   | AssetCreated, AssetDownloadCompleted, AssetReady, QCReport               |
| queue    | QueueItemAdded, QueueItemPromoted, QueueItemRemoved, CuratorDecision     |
| playout  | PlayoutSegmentAppended, PlayoutRotated, StreamEvent                      |
| policy   | PolicyPatched, PolicyRollback, AutopilotApplied, AutopilotRollback       |

## 🔐 Verificação

Cada fato:
1. É canonizado via `json_atomic::canonicalize()`
2. Recebe CID = `BLAKE3(canonical_bytes)`
3. É gravado em `{stream}.ndjson`
4. Pode ser recuperado por CID (busca em todos os streams)

### Verificar CID manualmente

```bash
# Get fact
FACT=$(curl -s http://localhost:8080/facts/a1b2c3d4...)

# Compute hash
echo -n "$FACT" | b3sum

# Compare with CID
```

## 🧪 Proof of Done (PoD)

```bash
#!/bin/bash
set -e

echo "1️⃣ Creating PlanCreated..."
RESPONSE=$(curl -s -X POST http://localhost:8080/facts \
  -H "Content-Type: application/json" \
  -d '{
    "type": "PlanCreated",
    "timestamp": "2026-01-10T20:00:00Z",
    "plan_id": "pod_test_001",
    "source": "youtube",
    "url": "https://example.com/test"
  }')

CID=$(echo $RESPONSE | jq -r '.cid')
echo "✅ CID: $CID"

echo ""
echo "2️⃣ Fetching by CID..."
FACT=$(curl -s http://localhost:8080/facts/$CID)
echo "✅ Fact retrieved"

echo ""
echo "3️⃣ Checking metrics..."
curl -s http://localhost:8080/metrics | grep 'facts_written_total{stream="plans"}'
echo "✅ Metrics OK"

echo ""
echo "🎉 Proof of Done complete!"
```

## 🏗️ Architecture

```
┌─────────────────────────────────────┐
│  HTTP API (Axum)                    │
│  POST /facts                        │
│  GET  /facts/{cid}                  │
│  GET  /facts/stream/{stream}        │
└───────────┬─────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│  json_atomic::canonicalize()        │
│  ↓                                   │
│  BLAKE3 → CID                       │
└───────────┬─────────────────────────┘
            │
            ▼
┌─────────────────────────────────────┐
│  LedgerManager                      │
│  ├─ plans.ndjson                    │
│  ├─ assets.ndjson                   │
│  ├─ queue.ndjson                    │
│  ├─ playout.ndjson                  │
│  └─ policy.ndjson                   │
└─────────────────────────────────────┘
```

## 🔄 Next Steps

- [ ] Assinatura Ed25519 opcional (feature `sign`)
- [ ] WAL (write-ahead log) para durabilidade
- [ ] Rotação diária automática
- [ ] Push para R2 (Cloudflare)
- [ ] Projeção D1 (Worker consome streams)

## 📄 License

MIT © 2026 danvoulez
