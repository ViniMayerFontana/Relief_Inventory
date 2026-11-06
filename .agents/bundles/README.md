# Relief Inventory — local DeepSeek Harness profile bundle

This directory holds local [DeepSeek Harness](https://github.com/deepseek-ai/deepseek-harness) profile bundles for this
repo. A bundle is a small npm-style package whose `package.json` declares a `dsh.bundle.patch`; the patch inserts or
overrides configuration rows (here: one `@deepseek-ai/dsh-agent-preset` row that declares the "Laravel Senior Engineer"
agent preset).

## Contents

- `relief-laravel-engineer/` — the **Laravel Senior Engineer** agent preset: the same tooling as the standard preset
  (fs, shell, skills, planning, delegation, compaction, …) with a `dsh-persona` prefix carrying the repo's Senior PHP &
  Laravel Software Engineer role (see `.agents/skills/laravel-senior-engineer/SKILL.md`).
- `relief-vue-frontend-engineer/` — the **Vue.js Senior Front-end Engineer** agent preset: the same tooling as the
  standard preset with a `dsh-persona` prefix carrying the repo's Senior Vue.js Front-end Engineer & Architect role
  (see `.agents/skills/vue-senior-frontend-engineer/SKILL.md`).

## Install / update

With the plugin manager (from any DSH session in this repo, or the Web **Plugins** page):

```
plugin_manager install_bundle target="link:C:/projects/Relief_Inventory/.agents/bundles/relief-laravel-engineer"
plugin_manager install_bundle target="link:C:/projects/Relief_Inventory/.agents/bundles/relief-vue-frontend-engineer"
```

The `link:` spec keeps the package files in this repo, so edits to `cordis.patch.yml` reach the profile on the next
reload (restart or HMR recomposition). New sessions can then select the "Laravel Senior Engineer" preset; existing
sessions keep the composition they started with.
