# I18N_HANDOFF — Handoff de continuidade da internacionalização (EN → pt-BR)

> **Para quem lê**: o Lead e o agente I18N que vão continuar este trabalho em outra máquina.
> **Regra de ouro**: este documento + `I18N_WORK_REPORT.md` + `I18N_COVERAGE_REPORT.md` + `dev/notes/I18N_GLOSSARY.md`
> (canônico) contêm TUDO. Não dependa de arquivos gitignored (`.i18n-queue/`, `.i18n-cache/`) — o que é essencial
> foi versionado em `dev/patches/localizer/`. O perfil do agente está em `Agents/I18N_COPILOT.md` (canônico, versionado).
> Gerado em 2026-11-12 (máquina PLANCK) pelo Lead da sessão, a pedido do usuário, para continuidade no outro computador.

---

## 1. Estado em uma página

- **Branch `i18n-pt-br-pilot`** — 27 commits revisados (base `main` @ f58c8c9). **NÃO pushado** (regra da casa: push só se o usuário pedir). Working tree limpa no último commit.
- **Cobertura: 100% das superfícies** — 88/88 páginas Vue, 39 componentes, 37 Blade, 9 help guides pt-BR, locales Laravel (`lang/pt_BR`: validation/pagination/auth/passwords/mail/notifications/reports/help + espelhos en), e-mails, notificações de banco, papel A4 dos relatórios.
- **Locale JS: 372 → 2968 chaves** (pt_BR 97% — as "faltantes" são 101 verbatims intencionais; **0 chaves de fato faltantes**).
- **CLI `@ai-localizer` v0.1.1 parcheada em 4 rounds** (Issues 1–11 + 3.1a–e) — patch cumulativo **versionado**: `dev/patches/localizer/core-round3.patch` (203 KB, 18 diffs sobre o upstream HEAD `6d478b3`) + 4 suítes de regressão no mesmo diretório.
- **Pendente** (seção 6): suíte Pest não validada nesta máquina (faltava `mariadb-dump` no host — instalação interrompida pelo usuário antes de efeitos), dívidas conhecidas da CLI, PRs upstream (ação do usuário), decisão de push/PR para main, incertezas de glossário a validar com a operação.

## 2. Divisão de trabalho e agentes gerados

### 2.1 Papéis (como funcionou — replicar o modelo)

| Papel | Responsabilidade |
|---|---|
| **Usuário** | Missão, decisões de produto, aprovação de comandos sensíveis (concedeu acesso total), fork/push para PRs upstream |
| **Lead** | Decisões de domínio/tradução, revisão de diff linha a linha antes de TODO commit, commits (por lote, stage por nome, nunca em main, nunca push), ambiente da máquina, coordenação/encerramento |
| **Agente I18N (copiloto)** | Operar a CLI parcheada, ensaios em cópia antes de qualquer replace real, preencher traduções da fila, manter glossário working copy, redigir issues upstream, arquivos de locale. **Nunca commita, nunca injeta `$t()` à mão, nunca roda `cleanup --apply`** |
| **CLI `@ai-localizer` parcheada** | Todo o trabalho determinístico (scan/extract/replace/sync) — custo zero de tokens de IA |
| **Agente de help (descartável)** | Tradução dos 9 guias + wiring do `HelpGuide` — escopo disjunto, aposentado ao concluir |

### 2.2 Agentes gerados nesta fase (todos **aposentados** — não existem na outra máquina)

| Agente | Vida útil | Entregas principais | Como recriar |
|---|---|---|---|
| `i18n-copilot` | piloto → lote 5 | scaffolding, lotes 1–2, task-4, patches rounds 1–2 | Spawn DSH com briefing apontando para `Agents/I18N_COPILOT.md` + este handoff |
| `i18n-help-ptbr` | task-5 | wiring HelpGuide (`4618bda`), 9 guias (`12f8d1f`), HELP_CANDIDATES | Recriar SOMENTE se novos guias/ajustes de help forem necessários |
| `i18n-copilot-2` | cura-pass → lote final | cura-pass, task-8 Blade, task-9 scanner, componentes, lotes 6+7 e final, rounds 3–3.1e, relatório de cobertura | **É o modelo para o próximo agente** — ver template na seção 7.2 |

**Lição de gestão**: quando o contexto do agente esgota (lotes grandes), **aposente e re-spawne com handoff escrito** — sessão limpa erra menos. O usuário mandateou: mesmo erro/comando 3× sem progresso → parar e avisar.

### 2.3 Divisão de escopo entre agentes paralelos

- Copiloto: `resources/js/**`, `lang/**`, `.i18n-queue/**` — NUNCA `resources/help/**` nem `app/Support/HelpGuide.php` (agente de help).
- Help: `resources/help/**`, `app/Support/HelpGuide.php`, controladores que chamam HelpGuide, `lang/{en,pt_BR}/help.php`.
- Lead: commits, `dev/patches/**`, `I18N_*.md`, revisões pontuais (ex.: fix de chaves de objeto que quebraram o build — commit separado).

## 3. O que foi feito (commits, em ordem)

| Commit | Conteúdo |
|---|---|
| `eb7078b` | Piloto: scaffolding vue-i18n, lang/en+pt_BR auth/passwords, piloto CategoryEntry+Turnstile (máquina antiga) |
| `7bf4b99` | Lote 1: CategoryEntry/PackageTypes/Units |
| `3cdfc37` | Lote 2: LocationEntry/Forms |
| `86b91d3`,`024b808`,`9ead3d2`,`fa97e0c` | Task-4: locales Laravel (validation+attributes/pagination), FIRST_RUN.md, e-mails, notificações, ReportPaper A4 |
| `879678b` | Lote 3: People/Users |
| `4618bda`,`12f8d1f`,`5998a47` | Task-5 (help agent): wiring HelpGuide + 9 guias pt-BR + consolidação do vocabulário no glossário canônico |
| `df3bc9d` | Cura-pass das 13 páginas (round 3 real) |
| `95524ab` | Task-8: batch Blade dos 28 relatórios + DocumentRegistry |
| `e324e5a` | Task-9: receiving/sorting/scanner (protocolo SCANNING_INTERFACE_NOTES.md) |
| `dd89df1` | Componentes (39) + mini-cura das dispositions (round 3.1c/d) |
| `59362e5` | Lotes 6+7: 16 páginas admin/kiosk/orders + aspa-escapada |
| `414007d` | Lote final: 54 páginas restantes + `I18N_COVERAGE_REPORT.md` versionado |
| **PRÓXIMO (deste handoff)** | fix das 3 chaves de objeto que quebravam o build (Stats/SituationReport/WarehouseDashboard) + consolidação final do glossário + este handoff + patches versionados |

**Decisões de domínio registradas** (fonte: `dev/notes/I18N_GLOSSARY.md` — ler as 3 seções): Triagem (sorting) ≠ Separação (picking); Package Type→Tipo de embalagem ≠ Carton→caixa master; Role (RBAC)→Papel ≠ contact_role→Função do contato; Pull Sequence→Sequência de retirada; Pick Path→Rota de separação; Site (impressora)→Local (≠ website); Stack→Nível (⚠️ validar com a operação); Box/Case→caixa (⚠️ idem); Receiving→Recebimento; Order Filling→Atendimento de pedidos; Shipping→Expedição; Unknown Donor/roles/ACS Item#/Plus Code/BOL/Gaylord/Tote→verbatim; inventários de status de pedido e de oferta consolidados.

## 4. Como o trabalho é feito (protocolo — replicar exatamente)

**Ciclo por lote** (CHECK → DO → SAVE):

1. **CHECK**: ensaio em CÓPIA do repo (nunca no real primeiro); auditorias: attrs de input intocados, values de select/status literais, roles/STAFF_ROLE_NAMES literais, comentários intocados, em-dashes por byte (node), colisões de chaves, encoding UTF-8 por node (PS 5.1 exibe mojibake falso — confiar em bytes, não no display).
2. **DO**: `extract` → `git diff --stat` (aditivo) → `replace` → `git diff` completo → **divergência do ensaio = PARAR** → `translate plan` → preencher answers (mapa EN→PT derivado do pending por script — imune a erro de chave) → `translate apply` → `sync` → `cleanup` **SÓ dry-run** (Issue 7: `--apply` apagaria chaves de Blade) → `status`.
3. **SAVE**: diffs por página salvos em `.i18n-cache/<lote>-diffs/` → Lead revisa → Lead commita (stage por nome/arquivo, mensagem descritiva) → glossário working copy atualizado.

**Guardrails**: roles/names técnicos verbatim; values de select e chaves de mapas de dados NUNCA traduzidos; locale 100% texto puro (HTML fica no blade com `{{ }}`); nada de traçabilidade doador→prateleira nos textos (CLAUDE.md); ambíguos → resumo único por lote ao Lead.

**Comandos-chave** (com PHP/Composer no PATH): `node "$env:TEMP\i18n-localizer\localizer\packages\core\src\i18n\extract-i18n.js" <arquivos...>` (e `replace-i18n.js`) — os scripts de fase aceitam **lista explícita de arquivos** (escopo por lote). Status oficial: `npx.cmd -y @ai-localizer/cli status` com `$env:npm_config_cache` apontando para temp.

## 5. Ferramentas e artefatos (onde estão, como restaurar)

| Artefato | Onde | Como usar/restaurar |
|---|---|---|
| Patch cumulativo da CLI | `dev/patches/localizer/core-round3.patch` (versionado!) | Regravado em UTF-8/LF em 2026-11-12 (o original era UTF-16LE e o `git apply` não o lia). Re-clonar `https://github.com/VenMail/localizer` (HEAD `6d478b3`, usar `git -c http.sslBackend=openssl clone` — schannel quebra no DSH) + `git apply --exclude=package-lock.json core-round3.patch` (o lock do clone diverge do upstream) + `npm install --ignore-scripts` no clone. Nesta máquina o clone vive em `C:\projects\i18n-localizer\localizer`, com junction em `%TEMP%\i18n-localizer\localizer` para as suítes |
| Suítes de regressão da CLI | `dev/patches/localizer/test-*.js` (R2 23/23, R3 21/21, R3.1 40/40, Blade 10/10) | Rodar com `node <suite>` **depois** do patch aplicado — CommonJS: rodar FORA de pasta com `"type":"module"` (copiar as suítes para fora do repo). Nesta máquina: 4/4 PASS (2026-11-12) |
| Grants de teste | `dev/patches/localizer/test-grants.sql` (TESTING.md one-time setup) | Aplicar como root no container: `Get-Content ... | docker exec -i ri-test-mariadb mariadb -u root`. Em host Windows+Docker, usar também a variante `@'%'` para o `ri_test_provisioner` (PDO parte do host; o container vê o gateway NAT) |
| Glossário canônico | `dev/notes/I18N_GLOSSARY.md` | Fonte de verdade das traduções (3 seções + consolidações) |
| Glossário working copy | `.i18n-queue/GLOSSARY.md` (gitignored, sincroniza pela pasta) | Working detalhado por lote; consolidar no canônico ao fechar fases |
| Relatórios | `I18N_WORK_REPORT.md`, `I18N_COVERAGE_REPORT.md`, este arquivo | Cobertura por arquivo + dívidas numeradas |
| Issues upstream | `Agents/UPSTREAM_ISSUES.md` (11 issues prontas) + task-6 no quadro | Requer fork do usuário em VenMail/localizer; PRs pendentes |
| Fila de tradução | `.i18n-queue/pt_BR.pending.json` → `answers.json` | Limpa após cada lote (apply consome) |

**Fila de testes Pendente (root cause)**: a suíte Pest DEPENDE de `mariadb-dump`/`mysqldump` no HOST (app/Services/DatabaseTools.php:32 — snapshot do schema). Sem isso, **1246 testes falham com "mariadb-dump is not installed"** (falha ambiental em massa — NÃO é regressão). Instalação interrompida antes de efeitos nesta máquina. Como completar: baixar zip winx64 do https://archive.mariadb.org (testar 11.8.2/11.4.7/11.4.5), extrair `bin\` para `%LOCALAPPDATA%\Programs\mariadb-client`, adicionar ao PATH do usuário, `mariadb-dump --version` para confirmar.

**Banco de testes (Docker)**: Docker Desktop por usuário (`%LOCALAPPDATA%\Programs\DockerDesktop\Docker Desktop.exe` — iniciar antes de testar, daemon demora ~10s). Container `ri-test-mariadb` (mariadb:11, porta 3306, root sem senha, host `%`) foi criado — se a máquina não o tiver: `docker run -d --name ri-test-mariadb -e MARIADB_ALLOW_EMPTY_ROOT_PASSWORD=1 -e MARIADB_ROOT_HOST=% -e MARIADB_DATABASE=test_reliefinventory -p 3306:3306 mariadb:11` + grants do arquivo `dev/patches/localizer/test-grants.sql` (aplicar com `Get-Content ... | docker exec -i ri-test-mariadb mariadb -u root` — **não** inline: PowerShell estraga os backticks). `.env` mínimo (APP_KEY gerado + DB root@127.0.0.1) já existe no repo local (gitignored).

## 6. O que falta fazer (atualizado em 2026-11-12, máquina original)

**Sessão de 2026-11-12 (máquina original)**: ambiente reconstruído (PHP 8.4.27 + Composer em `%LOCALAPPDATA%\Programs\php84`, mariadb-dump 11.8.2 em `%LOCALAPPDATA%\Programs\mariadb-client`, Docker Desktop + container `ri-test-mariadb`), CLI parcheada validada **4/4 suítes** (clone em `C:\projects\i18n-localizer\localizer`), **bug de Blade descoberto e corrigido** (as chaves `__()` pontuadas dos 24 blades não tinham arquivo de lang — relatórios renderizavam chave crua em pt-BR; normalizadas para `commons./reports./errors.` + gerador `dev/scripts/i18n-lang-from-auto.cjs`), **bug upstream de Windows descoberto e corrigido** (`DatabaseTools::find()` usava `command -v`, inexistente no cmd.exe — fallback `where`; era a causa das ~1208 falhas em massa da suíte), Lote A (statusLabels + fluxo de updates, server-side) e Lote B (503 + expired-verification-link) concluídos, default pt-BR no provisionamento (.env.example + docker compose), `phpunit.xml` com locale fixo `en` para a suíte.

1. **Suíte Pest** — executada nesta máquina. Run 1 (com o bug de `command -v`): 1208 falhas em massa. Run 2 (pós-fix `DatabaseTools`): **1097 passed / 104 failed**. Das 104: **49 × `ViteManifestNotFoundException`** (testes que renderizam páginas exigem `public/build` — o build trava na quirk Defender×esbuild; **contornado com build dentro de container `node:22`**, manifest gerado), **~15 × PDFs** (WeasyPrint ausente no host — dívida de ambiente), **~11 × provisionamento** (grants aplicados com `@'%'`; o `user_host: 'localhost'` dos usuários criados pelo provisioner não casa com conexões do host via NAT do Docker — pendência de ambiente, não de código) e o restante a triar no re-run pós-manifest. **Descoberta crítica da sessão: a família restore (RestoreTest/WarehouseRestoreSetupTest/InstanceBackupTest) TRAVA a suíte no Windows** — o client `mariadb` carrega o dump por STDIN e o Symfony Process no Windows não fecha o stdin como no Linux (client espera input para sempre → suíte para no meio, log congela). Excluir esses 3 arquivos das rodadas locais no Windows até um fix upstream (`input: ''` no Process de `DatabaseTools::clientCommand()`/RestoreService — candidata a issue upstream). Dump/restore **funcionam fora dos testes** (probe standalone: dump 1.3s, completo ✓; restore-family falha por PDO host-NAT, não por código).
2. **Dívidas da CLI** (I18N_COVERAGE_REPORT.md §Dívidas) — pluralização; nó com `>` em atributo (CartonCodes); literais após chain (EmailSettings); `cleanup --apply` PROIBIDO; **nova**: literais `Yes`/`No`/`Never` no CSV de UserAdminController.
3. ~~statusLabels do UserAdminController + UpdateSender~~ ✅ 2026-11-12 — `lang/{en,pt_BR}/users.php` + `updates.php`, padrão notifications.php.
4. ~~errors/503 + expired-verification-link~~ ✅ 2026-11-12 — `lang/{en,pt_BR}/errors.php` (overlay do gerador).
5. **PRs upstream** (task-6) — ação do usuário (fork em VenMail/localizer + `Agents/UPSTREAM_ISSUES.md` tem 11 issues). **+1 candidata**: compatibilidade Windows do `DatabaseTools::find()` (correção já feita aqui — subir o patch junto).
6. ~~Push da branch~~ ✅ pushado pela máquina PLANCK. **PR para main** — decisão do usuário.
7. **Validar com a operação**: Stack→Nível; Box/Case→caixa; Receiving→Recebimento.
8. ~~Default pt-BR no provisionamento~~ ✅ 2026-11-12 — `.env.example` + `docker/compose.yaml` (x-settings).
9. **Build local**: quirk Defender×esbuild confirmada também nesta máquina ("Acesso negado" na remoção de temp do esbuild — mesmo com postinstall aprovado e binário validado). **Workaround operacional: build dentro de container `node:22`** (`docker run --rm -v .:/proj -w /proj node:22 sh -c "npm install --ignore-scripts && npm run build"` — 34s; ATENÇÃO: o npm do container reescreve `node_modules` com binários Linux — rodar `npm install` no host depois para restaurar). A validade do JS está provada por outros gates; solução definitiva por exclusão no Defender/WSL é decisão do usuário.

## 7. Como prosseguir (amanhã, outra máquina)

### 7.1 Checklist do Lead

1. Ler este arquivo + `I18N_COVERAGE_REPORT.md` §Dívidas + `dev/notes/I18N_GLOSSARY.md`.
2. `git status` limpo em `i18n-pt-br-pilot`? (o handoff + fixes foram commitados — ver `git log`).
3. Instalar ambiente conforme `I18N_WORK_REPORT.md` §ambiente (PHP 8.4 zip + Composer phar + PATH; Node; npm.cmd SEMPRE).
4. Restaurar CLI parcheada (tabela §5) e rodar as 4 suítes para validar.
5. Instalar mariadb-dump (§5) + subir container (§5) → rodar `vendor/bin/pest --parallel` → triar falhas ambientais × reais.
6. Decidir com o usuário: push da branch / PR para main; PRs upstream; dívidas da CLI como próxima fase.
7. Re-spawn do agente I18N (template §7.2) SOMENTE se houver trabalho de tradução novo (dívidas, novos textos upstream).

### 7.2 Template de spawn do agente I18N (ajustar conforme a tarefa)

> "Você é o `i18n-copilot-<n>` do repositório Relief Inventory. Língua de trabalho: português (BR). PRIMEIRO: leia `Agents/I18N_COPILOT.md` (perfil canônico) e `I18N_HANDOFF.md` (estado e protocolo). A CLI @ai-localizer está PATCHADA — restaure conforme I18N_HANDOFF.md §5 e valide com as suítes em `dev/patches/localizer/`. NUNCA commite (lead comita), NUNCA injete `$t()` à mão, `cleanup --apply` PROIBIDO, ensaio em cópia antes de qualquer replace, anti-loop: 3× mesmo erro → parar e avisar. Sua tarefa: <tarefa específica, com escopo de arquivos explícito>. Ambíguos de domínio: resumo único por lote para o lead."

## 8. Índice de referência

- `Agents/I18N_COPILOT.md` — perfil canônico do agente (guardrails, ferramentas)
- `Agents/UPSTREAM_ISSUES.md` — 11 issues prontas para o upstream da CLI
- `dev/notes/I18N_GLOSSARY.md` — glossário canônico (decisões de domínio)
- `I18N_WORK_REPORT.md` — como o trabalho é feito (processo) + encerramento
- `I18N_COVERAGE_REPORT.md` — cobertura por arquivo + dívidas numeradas
- `dev/patches/localizer/` — patch cumulativo + suítes de regressão
- `dev/notes/SCANNING_INTERFACE_NOTES.md` — regra para telas de scanner (ler antes de tocar nelas)
- `dev/TESTING.md` — banco de testes (grants, snapshot)
- Board de tarefas da sessão DSH (tasks 1–9, estados) — não sobrevive entre máquinas; o estado real está aqui
