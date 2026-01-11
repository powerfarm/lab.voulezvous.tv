# CONTEXT — voulezvous.tv

**Última atualização:** 2026-01-10  
**Status:** Fase A.1 (Ledger Baseline) — 70% implementado

---

## 🎯 Goal (uma frase)

TV 24/7 de filmes adultos programada por IA editorial: descobre vídeos, planeja com antecedência, baixa após PBD (play-before-download), garante QC técnico rigoroso, transmite HLS estável e aprende todo dia com Autopilot D+1.

---

## ✅ "Done" esta semana

- [x] Workspace Rust configurado com crates do logline-workspace
- [x] Infraestrutura Terraform (Cloudflare + LAB) completa
- [x] Configs (business_logic.yaml, sources.yaml, llm.toml)
- [x] `vvtv-ledger-svc` implementado (POST/GET facts, 5 streams NDJSON)
- [ ] PoD do ledger (3 curl tests)
- [ ] Build + deploy no LAB512

**Meta da semana:** Ledger rodando + 1 fato gravado e verificado.

---

## 📍 Current State

### Repositório
- **Path:** `/Users/ubl-ops/voulezvous.tv`
- **Estrutura:**
  ```
  voulezvous.tv/
  ├── Cargo.toml (workspace)
  ├── apps/vvtv-ledger-svc/  ✅ implementado
  ├── configs/               ✅ completo
  └── infra/
      ├── cloudflare/        ✅ Terraform pronto
      └── lab/               ✅ Terraform pronto
  ```

### Serviços (status)
- **vvtv-ledger-svc** → implementado, não buildado ainda
- **vv-fetcherd** → pendente
- **vv-plannerd** → pendente
- **vv-qcd** → pendente
- **Cloudflare Worker** → pendente

### Infraestrutura
- **LAB:** Mac mini M2 Pro (LAB512) — 32GB, macOS
- **Edge:** Cloudflare (R2, D1, Workers, Pages)
- **State:** Terraform Cloud (CF) + local (LAB)

### Domínios
- `voulezvous.tv` (principal)
- `api.voulezvous.tv` (Worker)
- `api-staging.voulezvous.tv` (staging)

---

## 🔒 Decisions Locked

1. **Stack 100% Rust** nos LABs (exceto Worker JS no edge)
2. **Ledger UBL como única fonte de verdade** (NDJSON canônico)
3. **Cloudflare minimal** (R2/Pages/Workers) — LAB faz o pesado
4. **json_atomic para todos os fatos** (canonização + BLAKE3 CID)
5. **TDLN Gate para business_logic.yaml** (políticas determinísticas)
6. **LLM como "azeite"** via MCP auditado (nunca governa)
7. **PBD obrigatório** (play-before-download) antes de cada asset
8. **QC inegociável:** VMAF≥90, LUFS -14±0.5dB, SSIM≥0.92

---

## 🔌 Interfaces & Crates

### Crates do logline-workspace (usadas)
```toml
json_atomic = "0.1.1"      # canonização + CID
logline-core = "0.1.1"     # lifecycle de registros
tdln-ast = "0.1.1"         # AST canônico
tdln-compiler = "0.1.1"    # NL → intent
tdln-gate = "0.1.1"        # policy gate
tdln-proof = "0.1.1"       # provas Merkle
tdln-brain = "0.2.0"       # LLM integration
lllv-core = "0.1.1"        # cápsulas verificáveis
lllv-index = "0.1.1"       # index + Merkle proofs
ubl-ledger = "0.3"         # NDJSON append-only
ubl-runtime = "0.3"        # router + handlers
ubl-office = "0.3"         # agent runtime
ubl-mcp = "0.2"            # MCP auditado
```

### Endpoints (quando deployado)
```
LAB (8080)
  POST   /facts               # grava fato canônico
  GET    /facts/{cid}         # busca por CID
  GET    /facts/stream/{s}    # lista stream
  GET    /health              # healthcheck
  GET    /metrics             # Prometheus

Worker (api.voulezvous.tv)
  GET    /packs               # lista packs LLLV
  GET    /proofs/:id          # retorna prova
  GET    /health
```

### Ledger Streams (5 NDJSON)
1. **plans.ndjson** — PlanCreated, PlanScheduledForDownload, PlanArchived
2. **assets.ndjson** — AssetCreated, AssetDownloadCompleted, QCReport
3. **queue.ndjson** — QueueItemAdded, CuratorDecision
4. **playout.ndjson** — PlayoutSegmentAppended, StreamEvent
5. **policy.ndjson** — PolicyPatched, AutopilotApplied

---

## 📋 Next 3 Tasks

### 1. **Build + PoD do vvtv-ledger-svc**
```bash
cd apps/vvtv-ledger-svc
cargo build --release
VVTV_LEDGER_DIR=/tmp/ledger cargo run &
./tests/pod.sh http://localhost:8080
```
**PoD:** 3 fatos gravados (PlanCreated, QCReport, PolicyPatched) e recuperados por CID.

### 2. **Deploy infra Terraform**
```bash
# Cloudflare
cd infra/cloudflare
terraform init
terraform apply -var-file=envs/prod.tfvars

# LAB
cd infra/lab
terraform init
terraform apply -var-file=vars/lab512.tfvars
```
**PoD:** Ollama rodando, Worker health OK, R2 bucket criado.

### 3. **Criar vv-plannerd (Fase B.1)**
- Lê `business_logic.yaml` compilado (tdln-compiler)
- Scoring (6 fatores) + diversidade
- Softmax determinístico (seed por slot)
- Escreve `PlanScheduledForDownload` no ledger

**PoD:** 100 candidatos → top-12 determinístico com mesmo seed.

---

## 🚫 Do-Not-Do List

- ❌ Não buildar Worker antes do ledger rodar
- ❌ Não implementar Curador antes do Planner funcionar
- ❌ Não mexer em streaming/HLS antes de QC estar verificado
- ❌ Não adicionar features ao ledger (keep it simple)
- ❌ Não tentar generalizar infra além do necessário

---

## 📚 Glossary

- **PBD** — Play-Before-Download: tocar 10-30s antes de baixar pra confirmar HD
- **CID** — Content ID: BLAKE3(canonical_bytes)
- **TDLN** — Intent OS: AST canônico + Gate + Proof
- **UBL** — Unified Business Ledger: NDJSON append-only
- **Cartão do Dono** — business_logic.yaml (políticas editoriais)
- **Curador Vigilante** — LLM via MCP que sugere reordenação (confidence ≥0.62)
- **Autopilot D+1** — ajustes automáticos às 03:00 UTC com canary
- **Softmax(T=0.6)** — seleção probabilística com temperatura 0.6
- **LAB512** — Mac mini M2 Pro, 32GB, /Users/ubl-ops/voulezvous.tv
- **R2** — Cloudflare object storage (S3-compatible)
- **D1** — Cloudflare SQL (SQLite)
- **VMAF** — Video quality metric (target ≥90)
- **LUFS** — Loudness Units Full Scale (target -14±0.5dB)
- **SSIM** — Structural Similarity Index (target ≥0.92)

---

## 🗂️ File Layout (LAB)

```
/var/lib/vvtv/
  ledger/
    plans.ndjson
    assets.ndjson
    queue.ndjson
    playout.ndjson
    policy.ndjson
  packs/           # LLLV index packs (antes de R2)
  work/            # transcodes temporários
  cache/           # LLM cache

/opt/vvtv/
  config/
    .env           # secrets (gerado por Terraform)
  logs/
    ollama.stdout.log
    runner.stdout.log
    ledger.log
```

---

## 🔄 Phases (roadmap)

### Fase A — Baseline verificável ✅ 70%
- [x] Workspace + configs
- [x] Infra Terraform
- [x] vvtv-ledger-svc implementado
- [ ] PoD do ledger
- [ ] Cartão do Dono → Intent + Gate

### Fase B — Pipeline de TV 🔜
- [ ] vv-plannerd (softmax + diversidade)
- [ ] vv-prefetchd (PBD)
- [ ] vv-qcd (VMAF/LUFS/SSIM)
- [ ] vv-queue (FIFO + Curador observer)
- [ ] vv-broadcastd (HLS + emergency loop)

### Fase C — Autonomia D+1 ⏳
- [ ] Autopilot (micro-ajustes com canary)
- [ ] SIRP envelopes (atomic-sirp)
- [ ] Projeção D1 no Worker

---

## 🧪 PoD Commands (quick reference)

```bash
# Build ledger
cd apps/vvtv-ledger-svc && cargo build --release

# Run ledger
VVTV_LEDGER_DIR=/tmp/ledger \
RUST_LOG=debug \
cargo run --release

# Test ledger
./tests/pod.sh http://localhost:8080

# Deploy Cloudflare
make cf-apply

# Deploy LAB
make lab-apply

# Check Ollama
curl http://localhost:11434/api/tags

# View ledger
cat /var/lib/vvtv/ledger/plans.ndjson | jq
```

---

## 🎯 Success Metrics (Fase A)

- ✅ Ledger aceita 3 tipos de fatos diferentes
- ✅ CID é estável (mesmo input → mesmo CID)
- ✅ Métricas Prometheus expostas
- ✅ Health check responde em <10ms
- ✅ NDJSON é humanamente legível

---

## 🤝 Como usar este Context Pack

**No início de TODA sessão sobre voulezvous.tv:**
1. Cole este arquivo inteiro
2. Diga: "Contexto carregado. Vou trabalhar em [tarefa específica]"
3. LLM já sabe tudo e executa sem perguntar

**Atualize semanalmente:**
- Current State
- Next 3 Tasks
- Fase (% de progresso)

---

**Time:** Dan (ubl-ops) + GitHub Copilot  
**Repo:** github.com/danvoulez (18 crates publicadas)  
**Foundation:** logline.foundation
