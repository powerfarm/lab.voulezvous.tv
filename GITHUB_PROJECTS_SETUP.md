# GitHub Projects — Mission Control Setup

**O que é:** Um GitHub Project que coordena os 3 workstreams (Registry, TV, Rust) com sistema de turnos e automações.

**Por quê:** Resolve "LLM esquece" (contexto nas issues) + permite trabalhar nos 3 projetos sem perder progresso.

---

## 🚀 Setup Rápido (20 minutos)

### 1. Criar o Project

**Decisão necessária:** Onde criar?
- **Opção A:** User `danvoulez` (mais leve, rápido)
- **Opção B:** Org `VoulezVous` ou `LogLine-Foundation` (centralizado, colaborativo)

**Comando:**
1. Ir para: https://github.com/users/danvoulez/projects (ou org)
2. Clicar **"New project"**
3. Nome: **"Mission Control"**
4. Descrição: "Coordenação de Registry, voulezvous.tv e Rust Workspace"
5. Template: **"Table"** (depois adicionamos views)

---

### 2. Criar Custom Fields

**Em: Project → ⚙️ Settings → Fields**

| Field | Type | Options |
|-------|------|---------|
| **Workstream** | Single select | `Registry`, `TV`, `Rust` |
| **Mode** | Single select | `Active`, `Capture` |
| **Outcome** | Text | "o que sai no mundo" |
| **Proof of Done** | Text | "como eu sei que terminou" |
| **Iteration** | Iteration | 1 semana (seg→dom) |

**Comandos (UI):**
1. Click **"+ New field"**
2. Name: `Workstream`, Type: `Single select`
3. Options: `Registry`, `TV`, `Rust`
4. Repetir para cada campo acima

---

### 3. Criar Views

**Em: Project → Views → + New view**

#### View 1: Hoje (Table)
- **Nome:** `Hoje`
- **Layout:** Table
- **Filtro:** `Mode:Active` AND `Status != Done`
- **Colunas visíveis:** Title, Workstream, Outcome, Proof of Done, Assignees

#### View 2: Inbox (Table)
- **Nome:** `Inbox`
- **Layout:** Table
- **Filtro:** `Mode:Capture` OR `Status:Triage`
- **Sort:** Created (newest first)

#### View 3: Board (Kanban)
- **Nome:** `Board`
- **Layout:** Board
- **Group by:** Status
- **Colunas:** Todo, In Progress, Done

#### View 4: Roadmap (Timeline)
- **Nome:** `Roadmap`
- **Layout:** Roadmap
- **Group by:** Iteration
- **Show:** Date ranges

#### View 5: Done/Archive
- **Nome:** `Done`
- **Layout:** Table
- **Filtro:** `Status:Done`
- **Sort:** Closed (newest first)

---

### 4. Ativar Automações Built-in

**Em: Project → ⚙️ → Workflows**

✅ Ativar:
- **Item closed** → Set Status to `Done`
- **Pull request merged** → Set Status to `Done`
- **Item reopened** → Set Status to `Todo`

✅ Configurar Auto-archive:
- **Em: Settings → Archive**
- Condition: `is:closed updated:<@today-14d`
- Action: Archive automatically

---

### 5. Setup Auto-add (com limitação do Free Plan)

**⚠️ Importante:** GitHub Free permite apenas **1 auto-add workflow**.

#### Opção A: Auto-add nativo (1 workflow apenas)
**Em: Project → ⚙️ → Workflows → Auto-add**
- Trigger: Issues & PRs
- Filters:
  - Repo: `danvoulez/*` (todos os repos)
  - Label: `mission-control` (marcar issues manualmente)

#### Opção B: GitHub Action (ilimitado)
Criar em cada repo: `.github/workflows/add-to-project.yml`

```yaml
name: Add to Mission Control

on:
  issues:
    types: [opened, labeled]
  pull_request:
    types: [opened, labeled]

jobs:
  add-to-project:
    runs-on: ubuntu-latest
    if: contains(github.event.issue.labels.*.name, 'mission-control') || contains(github.event.pull_request.labels.*.name, 'mission-control')
    steps:
      - uses: actions/add-to-project@v1.0.2
        with:
          project-url: https://github.com/users/danvoulez/projects/1
          github-token: ${{ secrets.ADD_TO_PROJECT_TOKEN }}
```

**Setup do GitHub App:**
1. GitHub App `minicontratos` já está configurado (App ID: 1460425)
2. Adicionar secrets no repo: `APP_GITHUB_ID` e `APP_GITHUB_PRIVATE_KEY` (⚠️ não podem começar com `GITHUB_`)
3. Ver instruções completas em: `.github/SECRETS.md`
4. Ou rodar script automatizado: `./scripts/setup-github-project.sh`

---

### 6. Templates de Issue

**Em cada repo:** Criar `.github/ISSUE_TEMPLATE/mission-control.yml`

```yaml
name: Mission Control Task
description: Task para o Mission Control Project
title: "[WORKSTREAM] "
labels: ["mission-control"]
body:
  - type: dropdown
    id: workstream
    attributes:
      label: Workstream
      options:
        - Registry
        - TV
        - Rust
    validations:
      required: true

  - type: textarea
    id: outcome
    attributes:
      label: Outcome (1 frase)
      description: O que sai no mundo quando isso termina?
      placeholder: "Ex: vvtv-ledger-svc rodando com 3 fatos gravados"
    validations:
      required: true

  - type: textarea
    id: pod
    attributes:
      label: Proof of Done
      description: Como você sabe que terminou?
      placeholder: "Ex: curl POST + GET retornam CID correto"
    validations:
      required: true

  - type: textarea
    id: context
    attributes:
      label: Context Pack / Links
      description: Links para CONTEXT_*.md ou docs relevantes
      placeholder: "Ex: CONTEXT_VOULEZVOUS_TV.md#next-3-tasks"

  - type: input
    id: next_action
    attributes:
      label: Next Action (1 linha)
      placeholder: "Ex: cargo build --release && ./tests/pod.sh"
```

---

## 🎯 Workflow Diário

### Começo do dia
1. Abrir view **"Hoje"**
2. Escolher 1 Workstream
3. Marcar 1-3 items como `Mode:Active`
4. Resto fica em `Mode:Capture`

### Durante o dia
- Ideia nova? → Criar issue rápida no **Inbox** (Mode:Capture)
- Terminou task? → Fechar issue (auto-move para Done)
- Stuck? → Comentar na issue (contexto salvo)

### Fim do dia
- Review: o que ficou Done hoje?
- Planejar: o que vai ser Active amanhã?

### Domingo (manutenção)
- Atualizar **Iteration** (nova semana)
- Revisar **Inbox** (triagem rápida)
- Atualizar **CONTEXT_*.md** se necessário

---

## 📊 Como LLM usa isso

### Sessão com LLM (você ou outro)
```markdown
[Cola CONTEXT_VOULEZVOUS_TV.md]

Vou trabalhar na issue #42:
[Cola o body da issue com Outcome + PoD]

Pode me ajudar com [tarefa específica]?
```

**Resultado:** LLM tem contexto completo em segundos.

---

## 🔄 Integração com Context Packs

| Context Pack | GitHub Project |
|--------------|----------------|
| `CONTEXT_VOULEZVOUS_TV.md` | Workstream: `TV` |
| `CONTEXT_RUST_WORKSPACE.md` | Workstream: `Rust` |
| `CONTEXT_REGISTRY.md` | Workstream: `Registry` |

**Fluxo:**
1. Context Pack define "Next 3 Tasks"
2. Cada task vira **1 issue** no Project
3. Issue tem campo `Outcome` + `Proof of Done`
4. LLM trabalha na issue (contexto linkado)
5. Issue fecha → vai pra Done → Context Pack atualiza

---

## 🚨 Troubleshooting

### "Auto-add não funciona"
- ✅ Verificar: label `mission-control` na issue
- ✅ Verificar: limite de 1 workflow no Free Plan
- ✅ Alternativa: usar GitHub Action `actions/add-to-project`

### "Views não filtram corretamente"
- ✅ Verificar: campos foram preenchidos (Workstream, Mode)
- ✅ Filtro: usar `Mode:is:Active` (não `Mode=Active`)

### "Automações não executam"
- ✅ Verificar: Workflows estão ativados em Settings
- ✅ Verificar: Status field não foi customizado demais

---

## 📝 Checklist de Setup

- [ ] Project criado (user ou org)
- [ ] 5 custom fields adicionados
- [ ] 5 views criadas (Hoje, Inbox, Board, Roadmap, Done)
- [ ] Automações built-in ativadas
- [ ] Auto-archive configurado (14 dias)
- [ ] Auto-add configurado (nativo ou Action)
- [ ] Issue templates criados em 1+ repo
- [ ] Primeira issue de teste criada e movida para Done

---

## 🎉 Proof of Done do Setup

Você consegue:
1. ✅ Abrir view "Hoje" e ver 0-3 items `Mode:Active`
2. ✅ Criar issue nova → aparece no Inbox automaticamente
3. ✅ Fechar issue → move para Done automaticamente
4. ✅ Issue antiga (14d) → arquiva automaticamente
5. ✅ Colar CONTEXT_*.md + issue body em LLM → contexto completo

---

## 📚 Recursos

- [GitHub Projects Docs](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Iteration Fields](https://docs.github.com/en/issues/planning-and-tracking-with-projects/understanding-fields/about-iteration-fields)
- [Built-in Automations](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations)
- [Auto-archive](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/archiving-items-automatically)
- [actions/add-to-project](https://github.com/actions/add-to-project)

---

**Próximo passo:** Decidir onde criar (user `danvoulez` ou org) e começar pelo item 1.
