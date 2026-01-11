# CONTEXT — LogLine Rust Workspace

**Última atualização:** 2026-01-10  
**Status:** Publicado (18 crates) — Pronto para consumo

---

## 🎯 Goal (uma frase)

Ecossistema Rust completo para computação verificável e confiança zero: JSON✯Atomic (canonização + BLAKE3), TDLN (Intent OS), LLLV (provas Merkle), UBL (ledger auditável) e runtime de agentes.

---

## ✅ "Done" esta semana

- [x] 18 crates publicadas em crates.io/users/danvoulez
- [x] Todas com `#![forbid(unsafe_code)]`, MSRV 1.75+, no_std ready
- [x] Documentação completa (docs.rs)
- [x] CI/CD (fmt, clippy, test, audit, deny)
- [x] Exemplos + benchmarks + testes
- [ ] ADR (Architecture Decision Records) no repo
- [ ] Website logline.foundation atualizado

**Meta:** Manter estabilidade e começar consumo em produção (voulezvous.tv).

---

## 📍 Current State

### Repositório Principal
- **Repo:** github.com/LogLine-Foundation/logline-workspace
- **Owner:** github.com/danvoulez
- **Publicado:** crates.io/users/danvoulez (18 crates)

### Estrutura (18 crates)

#### Core Protocol (JSON✯Atomic)
- `json_atomic` v0.1.1 — canonização + BLAKE3 + Ed25519
- `logline-core` v0.1.1 — lifecycle (DRAFT→COMMITTED/GHOST)
- `lllv-core` v0.1.1 — cápsulas criptográficas
- `lllv-index` v0.1.1 — Index Pack + Merkle proofs verificáveis

#### TDLN (Intent OS)
- `tdln-ast` v0.1.1 — AST determinístico
- `tdln-compiler` v0.1.1 — NL/DSL → AST canônico
- `tdln-gate` v0.1.1 — Policy Gate (preflight/decision)
- `tdln-proof` v0.1.1 — Proof bundle com Merkle
- `tdln-brain` v0.2.0 — Cognitive layer (LLM integration)

#### Atomic Family (v0.3.0)
- `atomic-types` — IDs, DIM, helpers de tempo
- `atomic-crypto` — BLAKE3, Ed25519, HMAC, did:key
- `atomic-codec` — JSON✯Atomic encode/decode
- `atomic-sirp` — Network capsule + receipts
- `atomic-runtime` — Router/handler com UBL logging

#### UBL (Unified Business Ledger)
- `ubl-ledger` — NDJSON writer (rotação + WAL + push R2)
- `ubl-mcp` v0.2.0 — Model Context Protocol (PolicyGate + AuditSink)
- `ubl-office` — Agent runtime (Wake·Work·Dream)

#### CLI
- `logline` v0.1.1 — Full stack bundle com CLI

---

## 🔒 Decisions Locked

1. **`#![forbid(unsafe_code)]`** em todas as crates
2. **MSRV 1.75+** (estável, não bleeding edge)
3. **no_std ready** onde faz sentido (core, crypto, codec)
4. **Versionamento SemVer rigoroso** (breaking = major bump)
5. **json_atomic** como base de canonização universal
6. **BLAKE3** para CID (não SHA256)
7. **Ed25519** (DV25) para assinaturas (opcional via features)
8. **TDLN Gate** nunca bloqueia por default (fail-open design)
9. **UBL ledger** sempre NDJSON append-only (sem SQL como source)
10. **MCP** com PolicyGate trait (provider-agnostic)

---

## 🔌 Interfaces & APIs

### json_atomic (canonização)
```rust
use json_atomic::{seal_value, verify_seal, canonicalize};

let fact = seal_value(&data, &signing_key)?;
verify_seal(&fact)?;
let cid = fact.cid_hex(); // BLAKE3
```

### tdln-compiler (NL → Intent)
```rust
use tdln_compiler::compile;

let result = compile("book a table for two")?;
println!("AST CID: {}", result.ast_cid);
println!("Canon CID: {}", result.canon_cid);
```

### tdln-gate (Policy Gate)
```rust
use tdln_gate::{Gate, PolicySet};

let policy = PolicySet::builder()
    .bound("amount", 0.0, 1000.0)
    .required("signature.magister")
    .build();

let gate = Gate::new(policy);
match gate.evaluate(&intent) {
    Decision::Permit => { /* OK */ },
    Decision::Deny(reason) => { /* blocked */ },
    Decision::Challenge => { /* human review */ },
}
```

### ubl-ledger (Append-only)
```rust
use ubl_ledger::{UblWriter, append_canonical};

let mut writer = UblWriter::new("/var/lib/ledger")?;
writer.append_canonical(&fact)?;
writer.rotate_daily()?;
```

### ubl-mcp (LLM via MCP)
```rust
use ubl_mcp::{PolicyGate, SecureToolCall};

let call = SecureToolCall::new("query_expand", params);
match gate.check(&call).await? {
    Decision::Permit => execute_tool(call).await?,
    _ => return Err("blocked"),
}
```

---

## 📋 Next 3 Tasks

### 1. **Consumo em produção (voulezvous.tv)**
- Usar `json_atomic`, `tdln-*`, `ubl-*` no vvtv-ledger-svc
- Validar APIs em workload real
- Coletar feedback de ergonomia

### 2. **ADRs no repo**
```
docs/adr/
  001-canonical-encoding.md
  002-gate-fail-open.md
  003-no-unsafe-policy.md
```

### 3. **Paper III (opcional)**
- "TDLN: Deterministic Intent OS for Zero-Trust Agents"
- Publicar em logline.foundation/papers/

---

## 🚫 Do-Not-Do List

- ❌ Não adicionar dependências pesadas (ex: tokio em crates core)
- ❌ Não quebrar no_std sem RFC
- ❌ Não mudar API pública sem bump de versão
- ❌ Não fazer breaking changes em patch releases
- ❌ Não adicionar unsafe sem justificativa documentada
- ❌ Não publicar sem passar CI (fmt + clippy + test + audit)

---

## 📚 Glossary

- **JSON✯Atomic** — Canonização RFC 8785 + BLAKE3 + Ed25519
- **CID** — Content ID: hex(BLAKE3(canonical_bytes))
- **TDLN** — The Deterministic Logic Notation (Intent OS)
- **DV25** — Deterministic Verification with Ed25519
- **LLLV** — LogLine Lookup Verify (Index Pack + Merkle)
- **UBL** — Unified Business Ledger (NDJSON append-only)
- **MCP** — Model Context Protocol (Anthropic spec)
- **Intent** — AST canônico (verb, slots, constraints)
- **Gate** — Policy checker (bounds, forbidden, required)
- **Proof Bundle** — Merkle root + trace + optional signature
- **Span** — Evento atômico no ledger (começo/fim de operação)
- **NDJSON** — Newline-Delimited JSON (1 linha = 1 fato)
- **Merkle Tree** — Árvore de hashes para prova de inclusão
- **VMAF/SSIM** — Métricas de qualidade de vídeo
- **LUFS** — Loudness Units Full Scale (áudio)

---

## 🗂️ Crate Dependency Graph

```
logline (CLI)
  ├─> json_atomic
  ├─> logline-core
  ├─> tdln-compiler
  │     ├─> tdln-ast
  │     ├─> tdln-proof
  │     └─> json_atomic
  ├─> lllv-index
  │     ├─> lllv-core
  │     └─> json_atomic
  └─> ubl-ledger
        └─> json_atomic

ubl-office
  ├─> ubl-runtime
  │     ├─> atomic-types
  │     ├─> atomic-codec
  │     └─> ubl-ledger
  ├─> tdln-brain
  │     ├─> tdln-ast
  │     └─> tdln-compiler
  └─> ubl-mcp
        ├─> tdln-gate
        └─> ubl-ledger
```

---

## 🔄 Release Process

### Checklist (antes de publicar)
1. `cargo fmt --all`
2. `cargo clippy --all-targets --all-features -- -D warnings`
3. `cargo test --all-features`
4. `cargo audit`
5. `cargo deny check`
6. Atualizar `CHANGELOG.md` (Keep a Changelog format)
7. Bump versão em `Cargo.toml` (SemVer)
8. Tag git: `v0.x.y`
9. `cargo publish -p <crate>`

### CI/CD (GitHub Actions)
```yaml
- Rust stable + nightly
- fmt, clippy, test
- cargo-audit
- cargo-deny
- docs.rs build simulation
```

---

## 🧪 Testing Strategy

### Unit tests
- Em cada módulo (`#[cfg(test)]`)
- Coverage target: ≥80%

### Integration tests
- `tests/` directory
- End-to-end flows (ex: seal → verify → retrieve)

### Property tests
- `proptest` para invariantes (ex: CID estável)

### Fuzzing (opcional)
- `cargo-fuzz` para parsers (AST, NDJSON)

### Benchmarks
- `criterion` para hot paths (canonização, hashing)

---

## 📊 Metrics & Observability

Cada crate com runtime expõe:
- `<operation>_duration_seconds` (histogram)
- `<operation>_total` (counter)
- `<operation>_errors_total` (counter by error type)

Padrão: Prometheus + tracing spans.

---

## 🌐 Public Endpoints

- **Docs:** docs.rs/logline-core (etc)
- **Crates:** crates.io/crates/json_atomic (etc)
- **Website:** logline.foundation
- **GitHub:** github.com/LogLine-Foundation/logline-workspace
- **Papers:** logline.foundation/papers/

---

## 🤝 Como usar este Context Pack

**No início de TODA sessão sobre logline-workspace:**
1. Cole este arquivo inteiro
2. Diga: "Contexto carregado. Vou trabalhar em [crate/issue específico]"
3. LLM já conhece toda a arquitetura e convenções

**Atualize quando:**
- Nova crate publicada
- Breaking change em API
- Decisão arquitetural importante (adiciona ADR)

---

## 🏗️ Project Phases

### Phase 0 — Foundation ✅ 100%
- Core protocol (json_atomic, logline-core)
- TDLN basics (ast, compiler, gate, proof)
- LLLV (core, index)
- UBL (ledger, types, crypto, codec)

### Phase 1 — Runtime & Agents ✅ 90%
- ubl-runtime, ubl-office, ubl-mcp
- atomic-sirp (network layer)
- tdln-brain (LLM integration)

### Phase 2 — Production Use 🔜
- voulezvous.tv deployment
- Performance tuning
- Field testing & feedback

### Phase 3 — Ecosystem ⏳
- Community crates
- Third-party integrations
- Academic papers

---

**Maintainer:** Dan (danvoulez)  
**Foundation:** LogLine Foundation  
**License:** MIT OR Apache-2.0  
**Status:** Production-ready
