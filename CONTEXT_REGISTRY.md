# CONTEXT — Chip Registry

**Última atualização:** 2026-01-10  
**Status:** Conceitual — Não implementado ainda

---

## 🎯 Goal (uma frase)

Registry universal de "chips" (componentes reutilizáveis): código, prompts, configs, modules Terraform — tudo verificável, versionado e com prova de origem via json_atomic + BLAKE3.

---

## ✅ "Done" esta semana

- [x] Conceito definido (registry de artifacts reutilizáveis)
- [ ] Spec escrita (o que é um "chip")
- [ ] Schema do manifest (chip.json)
- [ ] Backend escolhido (Cloudflare? Self-hosted?)
- [ ] CLI protótipo (`chip publish`, `chip install`)

**Meta:** Definir MVP scope e escolher stack.

---

## 📍 Current State

### Status
- **Fase:** Conceitual / Planning
- **Código:** 0%
- **Spec:** Draft mental

### Problema que resolve
Hoje você tem:
- Módulos Terraform espalhados
- Scripts shell copiados entre projetos
- Prompts reutilizáveis sem versionamento
- Configs (YAML/TOML) duplicadas

**Chip Registry resolve:** repo canônico + versionamento + verificação + discovery.

---

## 🔒 Decisions Locked

1. **Cada chip é um artifact verificável** (CID via json_atomic)
2. **Manifest canônico** (`chip.json` com schema rígido)
3. **Storage agnóstico** (pode ser R2, GitHub Releases, ou filesystem)
4. **CLI-first** (publish/install/search via CLI simples)
5. **Sem runtime** (chips são inertes até serem instalados)
6. **Versionamento SemVer** (major.minor.patch)
7. **Tags para discovery** (ex: `terraform`, `prompt`, `config`, `rust`)
8. **Assinatura opcional** (Ed25519 via DV25)

---

## 🔌 Interfaces (conceitual)

### CLI Commands
```bash
# Publish a chip
chip publish ./my-terraform-module --tag terraform --tag cloudflare

# Install a chip
chip install danvoulez/r2-bucket@1.0.0 --to ./infra/modules/

# Search registry
chip search terraform cloudflare

# Verify chip
chip verify danvoulez/r2-bucket@1.0.0

# List installed
chip list --local

# Update chip
chip update danvoulez/r2-bucket --to latest
```

### Manifest Schema (draft)
```json
{
  "name": "r2-bucket",
  "version": "1.0.0",
  "author": "danvoulez",
  "type": "terraform-module",
  "tags": ["terraform", "cloudflare", "r2", "storage"],
  "description": "Reusable Terraform module for Cloudflare R2 buckets",
  "files": [
    "main.tf",
    "variables.tf",
    "outputs.tf",
    "README.md"
  ],
  "dependencies": [],
  "license": "MIT",
  "signature": "optional-ed25519-sig"
}
```

### API Endpoints (se tiver backend)
```
POST   /chips              # publish chip
GET    /chips/:author/:name/:version
GET    /chips/:author/:name/versions
GET    /chips/search?tags=terraform,cloudflare
DELETE /chips/:author/:name/:version  # unpublish (owner only)
```

---

## 📋 Next 3 Tasks

### 1. **Escrever Spec completa**
Documento `SPEC.md` com:
- O que é um chip (definição rigorosa)
- Schema do manifest
- Tipos suportados (terraform, prompt, config, rust-crate, etc)
- Lifecycle (publish → verify → install → update)
- Assinatura e verificação

**PoD:** Spec revisada e sem ambiguidades.

### 2. **Protótipo CLI (MVP)**
```rust
// chip-cli/src/main.rs
use clap::{Parser, Subcommand};

#[derive(Parser)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    Publish { path: String },
    Install { chip: String },
    Search { tags: Vec<String> },
}
```

**PoD:** `chip publish` cria `.tar.gz` + `chip.json` + CID.

### 3. **Escolher backend**
Opções:
- **A) Cloudflare R2 + D1** (registry metadata em D1, blobs em R2)
- **B) GitHub Releases** (chips = releases, manifest = JSON no repo)
- **C) Self-hosted MinIO + SQLite** (LAB-only)

**PoD:** Decisão documentada em ADR.

---

## 🚫 Do-Not-Do List

- ❌ Não implementar antes da spec estar clara
- ❌ Não adicionar features "nice-to-have" no MVP
- ❌ Não buildar UI antes do CLI funcionar
- ❌ Não tentar resolver "dependency hell" na v1
- ❌ Não fazer registry privado sem autenticação (security risk)

---

## 📚 Glossary

- **Chip** — Artifact reutilizável (código, config, prompt, module)
- **Manifest** — `chip.json` com metadata do chip
- **CID** — Content ID: BLAKE3(canonical manifest + files)
- **Registry** — Repositório central de chips publicados
- **Install** — Copiar chip do registry para local
- **Publish** — Enviar chip local para registry
- **Tag** — Categoria (ex: `terraform`, `rust`, `prompt`)
- **Author** — Username do publicador (ex: `danvoulez`)
- **Version** — SemVer (ex: `1.0.0`)
- **Signature** — Assinatura Ed25519 opcional do author

---

## 🗂️ Chip Types (planejados)

| Type              | Exemplo                          | Files                     |
|-------------------|----------------------------------|---------------------------|
| terraform-module  | r2-bucket                        | `*.tf`                    |
| rust-crate        | my-util-crate                    | `src/`, `Cargo.toml`      |
| prompt            | system-prompt-curator            | `prompt.txt`              |
| config            | business-logic-template          | `*.yaml`, `*.toml`        |
| script            | bootstrap-ollama                 | `*.sh`, `*.py`            |
| docs              | api-reference                    | `*.md`, `*.pdf`           |

---

## 🔄 Workflow (publish → install)

### Publish
1. Dev cria chip localmente
2. Escreve `chip.json` (ou gera com `chip init`)
3. Roda `chip publish`
   - Valida manifest
   - Computa CID
   - (Opcional) Assina com Ed25519
   - Envia para registry
4. Registry confirma com CID

### Install
1. User roda `chip install danvoulez/r2-bucket@1.0.0`
2. CLI baixa do registry
3. Verifica CID
4. (Opcional) Verifica assinatura
5. Extrai files para `--to` path
6. Registra em `.chip/installed.json` local

### Search
1. User roda `chip search terraform cloudflare`
2. CLI consulta registry (API ou index local)
3. Retorna lista de chips com match
4. User escolhe e instala

---

## 🧪 MVP Scope

**In:**
- ✅ CLI (`publish`, `install`, `search`)
- ✅ Manifest schema (`chip.json`)
- ✅ CID computation (BLAKE3)
- ✅ Filesystem storage (backend A)
- ✅ Basic verification

**Out (v2+):**
- ❌ Dependency resolution
- ❌ Private registry
- ❌ Web UI
- ❌ Signatures (optional in v1)
- ❌ Mirroring

---

## 🌐 Architecture (tentativa 1)

```
┌────────────────────────────────┐
│  chip CLI (Rust)               │
│  ├─ publish                    │
│  ├─ install                    │
│  └─ search                     │
└────────┬───────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│  Registry Backend              │
│  ├─ Metadata (D1 / SQLite)     │
│  └─ Blobs (R2 / MinIO / GH)    │
└────────────────────────────────┘
```

---

## 🤝 Como usar este Context Pack

**No início de TODA sessão sobre Registry:**
1. Cole este arquivo inteiro
2. Diga: "Contexto carregado. Vou trabalhar em [spec/CLI/backend]"
3. LLM já sabe o conceito e pode ajudar a implementar

**Atualize quando:**
- Spec finalizada
- MVP implementado
- Decisões de backend tomadas

---

## 💡 Use Cases

1. **Terraform modules** — publicar `r2-bucket`, reusar em 3 projetos
2. **System prompts** — versionar prompts do Curador, A/B test
3. **Configs** — business_logic.yaml templates com variações
4. **Scripts** — bootstrap scripts de LAB, reusar em múltiplas máquinas
5. **Rust utilities** — small crates sem overhead de crates.io

---

## 🎯 Success Metrics (MVP)

- ✅ 1 chip publicado e instalado com sucesso
- ✅ CID verificado manualmente (mesmo input → mesmo CID)
- ✅ Search retorna chips por tags
- ✅ CLI é self-documenting (`chip help`)
- ✅ Backend escolhido e funcionando

---

## 🏗️ Project Phases

### Phase 0 — Spec & Design ⏳ 20%
- [ ] SPEC.md completo
- [ ] ADR: Backend choice
- [ ] Schema do manifest final

### Phase 1 — MVP CLI 🔜
- [ ] `chip init`
- [ ] `chip publish`
- [ ] `chip install`
- [ ] `chip search`

### Phase 2 — Backend Integration 🔜
- [ ] Cloudflare D1 + R2
- [ ] Verification de CID
- [ ] Error handling robusto

### Phase 3 — Polish ⏳
- [ ] Assinaturas Ed25519
- [ ] Dependency resolution básico
- [ ] Web UI (opcional)

---

**Maintainer:** Dan (danvoulez)  
**Status:** Conceitual  
**Priority:** Medium (depois de voulezvous.tv MVP)  
**Related:** logline-workspace (reutiliza json_atomic, atomic-crypto)
