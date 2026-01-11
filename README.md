# VVTV — Voulezvous.TV

**TV 24/7 programada por inteligência editorial**

Stack 100% Rust + LogLine ecosystem + Cloudflare Edge

---

## 🎯 O que é

A VVTV é uma TV contínua de filmes adultos que:
- **Descobre** vídeos/músicas na internet
- **Planeja** com antecedência (T-12h → T-4h)
- **Baixa** após Play-Before-Download (PBD) para confirmar HD
- **Garante qualidade** (VMAF≥90, LUFS -14±0.5dB)
- **Transmite** em HLS/ABR estável
- **Aprende** todo dia (Autopilot D+1)

---

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────┐
│  Cloudflare Edge (Público)              │
│  ├─ Pages (vv-web)                      │
│  ├─ Worker (vv-api)                     │
│  └─ R2 (packs + proofs + assets)        │
└─────────────────────────────────────────┘
              ▲
              │ (sync)
              ▼
┌─────────────────────────────────────────┐
│  LAB (Mac minis)                        │
│  ├─ vv-fetcherd      (discovery)        │
│  ├─ vv-prefetchd     (PBD)              │
│  ├─ vv-qcd           (QC: VMAF/LUFS)    │
│  ├─ vv-plannerd      (softmax+curador)  │
│  ├─ vv-queue         (fila)             │
│  ├─ vv-broadcastd    (HLS)              │
│  ├─ ubl-ledgerd      (append-only)      │
│  ├─ indexer-lllv     (Merkle proofs)    │
│  ├─ mcp-hub          (LLM Pool)         │
│  └─ office-agentd    (orchestrator)     │
└─────────────────────────────────────────┘
```

---

## 📦 Crates (de crates.io/users/danvoulez)

- `json_atomic` v0.1.1 — canonização + BLAKE3
- `logline-core` v0.1.1 — lifecycle determinístico
- `lllv-core/lllv-index` v0.1.1 — Merkle proofs verificáveis
- `tdln-*` v0.1.1 / v0.2.0 — AST, compiler, gate, proof, brain
- `ubl-*` v0.2-0.3 — ledger, runtime, office, mcp

---

## 🚀 Quick Start

### 1. Build all services

```bash
cargo build --release --workspace
```

### 2. Setup configs

```bash
mkdir -p /var/lib/vvtv/{ledger,packs,work,cache}
cp configs/*.{yaml,toml} /etc/vvtv/
```

### 3. Run services (systemd)

```bash
sudo systemctl enable --now vvtv-ledger
sudo systemctl enable --now vvtv-office
sudo systemctl enable --now vvtv-fetcher
sudo systemctl enable --now vvtv-planner
sudo systemctl enable --now vvtv-broadcast
```

### 4. Check health

```bash
curl localhost:8080/healthz
tail -f /var/lib/vvtv/ledger/current.ndjson
```

---

## 🔐 Segurança

- `#![forbid(unsafe_code)]` em todos os bins
- TDLN Gate para business logic determinístico
- Ledger NDJSON canônico (BLAKE3 + Ed25519)
- LLM via MCP auditado (budgets + circuit-breaker)
- PBD obrigatório antes de download
- QC inegociável (VMAF/LUFS/compliance)

---

## 📊 Observabilidade

Métricas expostas em `:9090/metrics` (Prometheus):
- `ledger_lines_appended_total`
- `softmax_selection_time_ms{p95}`
- `mcp_calls_total{provider}`
- `curator_apply_rate`
- `kpi_retention_5min`
- `kpi_vmaf_avg`

---

## 📝 License

MIT © 2026 danvoulez
