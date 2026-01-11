# Mission Control — Quick Start (5 minutos)

✅ **Status:** GitHub App configurado, workflow pronto, templates criados.

---

## 🚀 Passos Rápidos

### 1. Criar o Project

**Escolher localização:**
- ✅ **Recomendado:** Org `VoulezVous` (já configurado no workflow)
- Alternativa: User `danvoulez` (atualizar workflow depois)

**Criar:**
```bash
# Abrir no browser
open https://github.com/orgs/VoulezVous/projects
```

1. Click **"New project"**
2. Nome: `Mission Control`
3. Template: **Table**
4. Save

Anotar o **número** do projeto (ex: `1` em `.../projects/1`)

---

### 2. Adicionar Secrets

**Ir para:**
```bash
open https://github.com/danvoulez/lab.voulezvous.tv/settings/secrets/actions
```

**Adicionar 2 secrets:**

| Name | Value |
|------|-------|
| `APP_GITHUB_ID` | `1460425` |
| `APP_GITHUB_PRIVATE_KEY` | [PEM do arquivo protegido] |

⚠️ **Nota:** Secret names cannot start with `GITHUB_`

**PEM format:**
```
-----BEGIN RSA PRIVATE KEY-----
[múltiplas linhas de base64]
-----END RSA PRIVATE KEY-----
```

⚠️ **Importante:** Cole o PEM completo, incluindo as linhas BEGIN/END.

---

### 3. Instalar GitHub App

**Ir para:**
```bash
open https://github.com/apps/minicontratos
```

1. Click **"Install"** ou **"Configure"**
2. Select: **danvoulez** (user account)
3. Repository access: **All repositories** (ou selecionar `lab.voulezvous.tv`)
4. Permissions (verificar):
   - ✅ Issues: Read & Write
   - ✅ Pull Requests: Read & Write
   - ✅ Projects: Read & Write
5. Save

---

### 4. Atualizar Project URL

Editar: `.github/workflows/add-to-project.yml`

**Se projeto na org VoulezVous (número 1):**
```yaml
project-url: https://github.com/orgs/VoulezVous/projects/1
```

**Se projeto no user danvoulez (número 1):**
```yaml
project-url: https://github.com/users/danvoulez/projects/1
```

Commit e push.

---

### 5. Teste Rápido

**Criar issue de teste:**
```bash
cd /Users/ubl-ops/voulezvous.tv

gh issue create \
  --title "✅ Test Mission Control" \
  --body "Verificar que workflow funciona" \
  --label "mission-control"
```

**Verificar:**
1. ✅ Issue criada
2. ✅ Workflow rodou: https://github.com/danvoulez/lab.voulezvous.tv/actions
3. ✅ Issue apareceu no Project

**Se funcionou:**
```bash
gh issue close $(gh issue list --label "mission-control" --limit 1 --json number -q '.[0].number')
```

---

### 6. Configurar Custom Fields (no Project UI)

**Ir para:** Project → ⚙️ Settings → Fields

**Adicionar 5 campos:**

| Field | Type | Options/Description |
|-------|------|---------------------|
| `Workstream` | Single select | `Registry`, `TV`, `Rust` |
| `Mode` | Single select | `Active`, `Capture` |
| `Outcome` | Text | "O que sai no mundo" |
| `Proof of Done` | Text | "Como sei que terminou" |
| `Iteration` | Iteration | 1 semana (seg→dom) |

---

### 7. Criar Views (no Project UI)

**No Project → Views → + New view:**

#### View "Hoje" (Table)
- **Filtro:** `Mode:Active` AND `Status != Done`
- **Colunas:** Title, Workstream, Outcome, Proof of Done

#### View "Inbox" (Table)
- **Filtro:** `Mode:Capture` OR `Status:Triage`
- **Sort:** Created (newest first)

#### View "Board" (Kanban)
- **Layout:** Board
- **Group by:** Status

#### View "Roadmap" (Timeline)
- **Layout:** Roadmap
- **Group by:** Iteration

#### View "Done" (Table)
- **Filtro:** `Status:Done`
- **Sort:** Closed (newest first)

---

### 8. Ativar Automações

**No Project → ⚙️ Settings → Workflows:**

✅ Ativar:
- **Item closed** → Set Status to `Done`
- **Item reopened** → Set Status to `Todo`

**No Project → ⚙️ Settings → Archive:**
- Condition: `is:closed updated:<@today-14d`
- Action: Archive automatically

---

## 🎯 Primeira Task Real

**Criar usando template:**
```bash
gh issue create \
  --template mission-control \
  --title "[TV] Build vvtv-ledger-svc"
```

**Ou na UI:**
- Go to: Repo → Issues → New issue
- Template: **"Mission Control Task"**
- Preencher:
  - Workstream: `TV`
  - Outcome: "vvtv-ledger-svc rodando com 3 fatos gravados"
  - Proof of Done: "curl POST + GET retornam CID correto"
  - Context: `CONTEXT_VOULEZVOUS_TV.md#next-3-tasks`
  - Next Action: `cargo build --release && ./tests/pod.sh`

**No Project:**
1. Abrir view **"Inbox"**
2. Achar a issue recém-criada
3. Preencher campos: `Mode:Active`, `Workstream:TV`
4. Mover para **"Hoje"** view

---

## 🔄 Workflow Diário

### Manhã
1. Abrir view **"Hoje"**
2. Ver tasks `Mode:Active`
3. Escolher 1 pra trabalhar

### Durante
- Trabalhar na task
- Comentar progresso na issue
- Ideia nova? → Criar issue com `Mode:Capture` (vai pro Inbox)

### Noite
- Fechar issues concluídas (auto-move pra Done)
- Planejar próxima `Active` pra amanhã

---

## 📋 Checklist

- [ ] Project criado (danvoulez user ou VoulezVous org)
- [ ] 2 secrets adicionados (`APP_GITHUB_ID`, `APP_GITHUB_PRIVATE_KEY`)
- [ ] GitHub App instalado (danvoulez account)
- [ ] Project URL atualizado no workflow
- [ ] Issue de teste criada e movida pro Project
- [ ] 5 custom fields criados
- [ ] 5 views criadas (Hoje, Inbox, Board, Roadmap, Done)
- [ ] Automações ativadas (close→Done, auto-archive 14d)
- [ ] Primeira task real criada e marcada `Active`

---

## 🆘 Troubleshooting

### "Workflow não roda"
✅ Verificar label `mission-control` na issue
✅ Verificar secrets `APP_GITHUB_ID` e `APP_GITHUB_PRIVATE_KEY` configurados
✅ Verificar GitHub App instalado

### "Issue não aparece no Project"
✅ Verificar project URL no workflow
✅ Verificar App tem permissão de Projects (Read & Write)
✅ Verificar workflow rodou com sucesso (Actions tab)

### "Não consigo criar campos"
✅ Ir em Project → ⚙️ (canto superior direito) → Settings
✅ Scroll até "Fields"
✅ Click "+ New field"

---

## 📚 Docs Completas

- **Setup completo:** [GITHUB_PROJECTS_SETUP.md](GITHUB_PROJECTS_SETUP.md)
- **Secrets detalhados:** [.github/SECRETS.md](.github/SECRETS.md)
- **Script automático:** `./scripts/setup-github-project.sh`
- **Architecture:** [ADR-002-github-projects.md](ADR-002-github-projects.md)

---

**Tempo total:** ~15 minutos (5 min setup técnico + 10 min config UI)

**Proof of Done:**
✅ Criar issue → aparece no Inbox → fechar → vai pra Done
