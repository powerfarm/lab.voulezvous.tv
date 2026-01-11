# ADR-002: GitHub Projects como Mission Control

**Status:** Aprovado  
**Data:** 2026-01-11  
**Contexto:** Gerenciar 3 projetos paralelos (Registry, voulezvous.tv, Rust Workspace)

---

## Decisão

Usar **1 GitHub Project** ("Mission Control") para coordenar os 3 workstreams, com sistema de turnos via campo `Mode` (Active/Capture) e views filtradas.

---

## Consequências

### ✅ Positivas
- **Elimina "esquecimento" de LLM** — contexto mora nas issues
- **Zero culpa de não focar** — sistema de turnos oficial
- **Automações nativas** — issues fechadas → Done automaticamente
- **Histórico auditável** — tudo em git + project board

### ⚠️ Atenções
- **Disciplina mínima** — marcar Mode:Active diariamente
- **Auto-add limitado** no plano Free (1 workflow) — usar GitHub Action se precisar
- **Manutenção semanal** — atualizar Iteration e revisar Inbox

---

## Implementação

Ver [GITHUB_PROJECTS_SETUP.md](GITHUB_PROJECTS_SETUP.md) para passo-a-passo.

---

## Referências

- [GitHub Projects Docs](https://docs.github.com/en/issues/planning-and-tracking-with-projects)
- [Built-in Automations](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/using-the-built-in-automations)
- [Auto-add Items](https://docs.github.com/en/issues/planning-and-tracking-with-projects/automating-your-project/adding-items-automatically)
