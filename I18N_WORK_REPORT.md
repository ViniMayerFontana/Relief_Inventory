# I18N_WORK_REPORT — Como o trabalho de internacionalização (EN → pt-BR) está sendo desenvolvido

> Relatório de processo gerado em 2026-11-10 (máquina PLANCK), para o usuário dono do projeto.
> Estado: branch `i18n-pt-br-pilot`, 7 commits revisados, pipeline com 81 chaves na base (pt-BR 88% — as "faltantes" são verbatim intencionais).
> Este arquivo é um relatório do usuário (não versionado por enquanto); as fontes canônicas do processo são
> `Agents/I18N_COPILOT.md` (perfil do agente), `dev/notes/I18N_GLOSSARY.md` (glossário) e `Agents/UPSTREAM_ISSUES.md` (limitações da CLI).

---

## 1. Quem faz o quê (separação de papéis)

| Papel | Responsabilidade | Não faz |
|---|---|---|
| **Usuário** | Missão, decisões de produto (ex.: default pt-BR no provisionamento), fork/push para os PRs upstream | — |
| **Lead (eu)** | Decisões de domínio/tradução, revisão linha a linha de cada diff, commits (por lote, stage por nome, sem push), ambiente da máquina (PHP, Composer, pint), aprovação de qualquer escrita em massa | Traduzir sem contexto; commitar sem revisar |
| **i18n-copilot (agente)** | Operar a CLI, ensaios em cópia, preencher traduções da fila, manter o glossário working copy, redigir issues upstream, arquivos de locale Laravel | Injetar `$t()`/`@lang` à mão; commitar; rodar `cleanup --apply` |
| **`@ai-localizer/cli`** (parcheada) | Todo o trabalho determinístico: escanear, extrair, reescrever código, sincronizar locales | Decisões de tradução |
| **Ferramentas de leitura** (`grep`/`glob`/`read`) | Mapeamento cirúrgico de contexto (o "mapa") | Substituir revisão humana |

## 2. Como o trabalho é separado (frentes)

### 2.1 Quadro de tarefas (dependências explícitas)

| Task | Escopo | Status |
|---|---|---|
| task-1 | Restaurar ambiente da máquina nova (npm, CLI, status) | ✅ concluída |
| task-2 | Corrigir a CLI localmente (Issues 1–3) + validar com ensaio | ✅ concluída |
| task-3 | **Escalar Vue por lotes** (~85 páginas + 39 componentes) | 🔄 em andamento (lote 3) |
| task-4 | Locales Laravel: validation/pagination, e-mails, notificações, A4, docs | ✅ concluída |
| task-5 | Help guides pt-BR + wiring do `HelpGuide` | ⏳ pronta |
| task-6 | Submeter PRs upstream (Issues 1–8) — depende de fork do usuário | ⏳ aguardando usuário |

### 2.2 Separação por superfície técnica

| Superfície | Método | Estado |
|---|---|---|
| **Páginas Vue** (89) | Pipeline CLI em lotes (lote = 2–3 páginas da mesma família) | 5/88 prontos (lotes 1–2); lote 3 em execução |
| **Componentes Vue** (39) | Mesmos lotes, depois das páginas | pendente |
| **Blade de relatórios** (28) | Papel/datas via helper + `reports.php`; títulos/corpos num batch próprio | papel+datas ✅; textos pendentes |
| **E-mails** (5) + assuntos | `lang/*/mail.php` + `trans()`/`__()` | ✅ |
| **Notificações de banco** | Tradução na gravação (`toDatabase` + `notifications.php`) | ✅ |
| **Locales Laravel** | `lang/pt_BR/validation.php` (111 chaves + 38 attributes), pagination, espelhos en | ✅ |
| **Help guides** (9 MD) | `resources/help/pt_BR/` + wiring do `HelpGuide` | pendente (task-5) |
| **PDFs (papel)** | `App\Support\ReportPaper::size()` condicional ao locale; etiquetas Avery fora (geometria fixa) | ✅ |

### 2.3 Por que em lotes pequenos

Cada lote de 2–3 páginas mantém o diff revisável linha a linha, isola regressões (rollback = `git checkout -- <arquivos>`),
e amortiza o custo fixo de revisão. A família é escolhida por semelhança estrutural (ex.: CRUDs do RIForm primeiro),
o que faz o ensaio do primeiro arquivo prever o comportamento dos demais.

## 3. O ciclo CHECK → DO → SAVE (executado a cada lote)

```
        ┌────────────────────────── CHECK ──────────────────────────┐
        │ 1. Ensaio em CÓPIA do repo (o --dry-run oficial não existe │
        │    no replace — descoberta nossa; ensaio = rede real)      │
        │ 2. Auditorias de segurança: zero "value: t(", 16 values    │
        │    intactos, blankQuestion() intacto, em-dash por byte     │
        │    (node), colisões de chaves, encoding UTF-8              │
        │ 3. Contexto de domínio: grep no código/modelo ANTES de     │
        │    traduzir termo ambíguo (ex.: PullSequence = ordem da    │
        │    rota de separação, não "reposição")                     │
        └────────────────────────────┬──────────────────────────────┘
                                     ▼
        ┌─────────────────────────── DO ────────────────────────────┐
        │ 4. extract (CLI) → diff --stat aditivo revisado            │
        │ 5. replace (CLI) → git diff completo                       │
        │ 6. divergência ensaio x real ⇒ PARAR                       │
        │ 7. translate plan → pending.json (só pares a traduzir)     │
        │ 8. IA preenche answers.json (glossário + confirmações do   │
        │    lead nos ambíguos) ⇒ apply ⇒ sync                       │
        └────────────────────────────┬──────────────────────────────┘
                                     ▼
        ┌─────────────────────────── SAVE ──────────────────────────┐
        │ 9. cleanup SÓ em dry-run (Issue 7: apagaria chaves de      │
        │    Blade) + status oficial                                 │
        │10. Lead revisa o diff completo; corrige gaps na revisão    │
        │11. pint (sessão do lead) + php -l + check de encoding      │
        │12. Commit por lote/bloco, stage POR NOME, sem push         │
        │13. Glossário working copy atualizado (mesmo termo = mesma  │
        │    tradução) ⇒ canônico versionado quando consolidado      │
        └───────────────────────────────────────────────────────────┘
```

**Evidências de funcionamento:** lote 1 (10 pares, apply 10/10), lote 2 (59 pares, apply 59/59, zero divergência do ensaio),
task-4 (5 blocos a–e, pint 21/21 + 3/3 PASS, `php -l` 16/16 e 3/3, encoding verificado por node).

## 4. Guardrails (o que o processo nunca faz)

1. **Nunca** traduzir `name` técnico de migrations/seeders/roles/status (compatibilidade upstream; roles ficam em inglês).
2. **Nunca** reescrever código Vue/Blade à mão para injetar `$t()` — injeção é 100% da CLI.
3. **Nunca** escrita em massa sem comando exato aprovado; **nunca** `cleanup --apply` (Issue 7).
4. Nunca traduzir sem contexto verificado no código (termo ambíguo → grep → decisão do lead).
5. Valores de `select` e dados gravados no banco permanecem literais (risco de corromper `v-model` — Issue 6).
6. E-mails: locale 100% texto puro; HTML fica no blade com `{{ }}` (dados do usuário seguem escapados — `UNTRUSTED_CONTENT`).

## 5. Decisões de domínio registradas (amostra do glossário)

| EN | pt-BR | Fundamento |
|---|---|---|
| Package Type(s) | Tipo(s) de embalagem | É a embalagem pela qual o item é pedido (`OrderLine`→packagetype; Case/Box) |
| Pull Sequence | Sequência de retirada | `locations.PullSequence` alimenta as pick sheets ("reposição" seria outro conceito) |
| Pick Path / pick sheet | Rota de separação / folha de separação | Comentário do `PickPath.vue`: ordem de caminhada dos separadores |
| Default Ordering Units | Unidades padrão para pedidos | Título da página Units; parse inequívoco |
| Question label | Rótulo da pergunta | Consistência label→rótulo ("enunciado" é de prova) |
| Status | Status (mantido) | Padrão de UI pt-BR; "Situação" descartado |
| Each (unidade) | Unidade | Tipo de unidade de item |

## 6. Estado atual (números de 2026-11-10)

- **Branch**: `i18n-pt-br-pilot` — 7 commits (pilot + lote 1 + lote 2 + task-4 a–d + A4). Sem push (política da sessão).
- **Pipeline Vue**: 81 chaves na base; pt-BR 71 (88%) — 10 verbatim intencionais; **0 chaves de fato faltantes**.
- **Laravel**: validation (111 + 38 attributes), pagination, auth/passwords, mail (57), notifications (7), reports (2), espelhos en.
- **Ambiente PLANCK reconstruído**: PHP 8.4.27 (extensões completas), Composer 2.11.2, vendor/ e node_modules, pint operante na sessão do lead.
- **Upstream**: 8 issues documentadas em `Agents/UPSTREAM_ISSUES.md` (issues 1–3 já corrigidas no clone local; PRs aguardam fork do usuário).

## 7. Economia de tokens (estratégia original × realidade)

| Camada da estratégia original | Status | Como funciona hoje |
|---|---|---|
| CLI = "músculo" (custo zero de IA) | ✅ seguida | extract/replace/apply/sync são determinísticos; IA só lê diffs pequenos e escreve a fila |
| Fila mínima (`pending.json` → `answers.json`) | ✅ seguida | 10 e 59 pares por lote; fila vazia fora do ciclo de tradução |
| MCP de memória de codebase = "mapa" | ⚠️ inexistente no DSH | Substituto: grep/glob cirúrgicos + glossário persistente (previsto no perfil, §2) |
| cleanup de órfãs | ⚠️ dry-run apenas | Issue 7 — `--apply` apagaria chaves usadas por Blade |

Custo extra aceito conscientemente: ensaios em cópia, revisões de diff do lead e patches da CLI — são o preço da
**corretude** (o CLI v0.1.1 tinha bugs que corromperiam strings/dados); patches são one-time e os PRs upstream os amortizam.

## 8. Pendências e próximos passos

1. **Lote 3+** (em curso): `People.vue` + resto do setup → depois por área (receiving, orders, inventory, reports…).
2. **Round de patches da CLI**: `:options` bound, `newrecordcaption`, mustache/ternários completos (Issues 8+), labels de 1 palavra.
3. **Batch Blade**: títulos/corpos dos 28 relatórios.
4. **Task-5**: help guides pt-BR + wiring do `HelpGuide` (edição Vue fora da CLI — acordo explícito).
5. **Usuário**: fork para PRs upstream; decisão sobre default pt-BR no provisionamento; MariaDB (Docker) quando rodarmos a suíte de testes.
