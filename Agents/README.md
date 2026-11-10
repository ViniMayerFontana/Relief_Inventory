# Agents

Perfis de agentes de IA instalados/instaláveis neste repositório (DeepSeek Harness e outros harnesses).

- `I18N_COPILOT.md` — agente copiloto de internacionalização (EN → pt-BR) para este projeto
  (Laravel 13 + Inertia 2 + Vue 3). Usa a CLI npm `@ai-localizer/cli` para as modificações
  determinísticas de código e a fila `.i18n-queue/` para as traduções. Nome do teammate no
  DeepSeek Harness: `i18n-copilot`. Espelho de runtime (não versionado): `.dsh/agents/i18n-copilot.md`.

- `UPSTREAM_ISSUES.md` — issues prontas para abrir no repo upstream da CLI `@ai-localizer/cli`
  (https://github.com/VenMail/localizer), documentando as limitações encontradas no piloto de
  i18n de 2026-11-09 (títulos e corpos em inglês, prontos para colar no GitHub).

Regra prática: se um agente aqui divergir do seu espelho de runtime, vale a cópia desta pasta.
