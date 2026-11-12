<!-- Cópia canônica e versionada deste glossário. Working copy (gitignored): .i18n-queue/GLOSSARY.md -->

# Glossário i18n — Relief Inventory (EN → pt-BR)

Fonte de verdade das escolhas de tradução. Mesmo termo = mesma tradução, em todas as telas.
Tom: profissional, logístico, adequado a operações de defesa civil e governo.

## Termos definidos

| EN | pt-BR | Notas |
|---|---|---|
| pallet | pallet | termo do domínio logístico; mantido em inglês |
| Pallet Report | Relatório de pallet | título do relatório PDF |
| Item Category Entry | Cadastro de categorias de itens | título da página (`<Head>`) |
| Item Category Management | Gerenciamento de categorias de itens | título do formulário (prop `title` do RIForm) |
| Category Name | Nome da categoria | label de campo; minúsculas em pt-BR |
| Search by Category Name... | Buscar por nome da categoria... | placeholder de busca |
| Turn it off | Desative-o | destaque (`<strong>`) na página de erro do Turnstile |
| Or give it keys | Ou forneça as chaves | destaque (`<strong>`) |
| set X to Y | defina X como Y | padrão para instruções de configuração |
| Cloudflare Turnstile | Cloudflare Turnstile | nome de produto; mantido |
| This page isn't set up yet | Esta página ainda não está configurada | `<h1>` da página de erro |
| dashboard | painel/dashboard | "dashboard do Cloudflare" quando referente ao produto |

## Limitações conhecidas da CLI `@ai-localizer/cli` v0.1.1 (achadas no piloto 2026-11-09)

1. **Falso positivo**: o comando `docker compose up -d` virou chave
   (`views.Errors.TurnstileMisconfigured.text.docker_compose_up_d`) — o backend Blade
   não roda validators de código. Tratamento: valor **VERBATIM em inglês** no
   `answers.json` (a saída renderizada fica idêntica ao original; nunca traduzir
   comandos/config).
2. **Wrap parcial**: os fragments `— set` (`commons.Commons.text.set`),
   `; then run:` e `, and set both` (views) são restos de parágrafos que contêm
   `<code>` inline; o backend Blade não injeta esses fragments (o parágrafo tem
   tags dentro). Estão traduzidos na base para consistência, mas não aparecem
   na tela.
3. `VueReplacer` para no primeiro `</template>` interno (regex não-gananciosa) —
   páginas com slots (todas as que usam RIForm) têm cobertura mínima.
4. Backend Blade sem alias de namespace `Commons` — textos de até 2 palavras
   nunca são substituídos em Blade.
5. Inconsistência de kind: o extract registra `<h1>` como `text`, o replacer
   procura `heading` — `<h1>` não é substituído.
6. Textos Vue com mustache `{{ }}` não são extraídos.
7. Chaves da fila vêm prefixadas pelo stem do arquivo de locale
   (`pages.Pages.title...`); o `answers.json` deve espelhar as chaves do
   `pending.json` verbatim.

## Notas de ambiente (para sessões futuras)

- A CLI está instalada **globalmente** (`npm.cmd i -g @ai-localizer/cli`); os scripts de
  fase do core ficam em
  `C:\Users\Vini\AppData\Roaming\npm\node_modules\@ai-localizer\cli\node_modules\@ai-localizer\core\src\i18n\`.
- Nesta máquina, `vite build` falha por interferência de antivírus/Defender com o binário
  esbuild ("Access is denied" na exclusão do temp, mesmo sem confinamento) — quirk
  ambiental, não relacionado ao i18n.
- As 5 limitações reportáveis têm issues redigidas em `Agents/UPSTREAM_ISSUES.md`
  (títulos e corpos em inglês, prontos para colar no GitHub).

## Termos dos help guides (task-5, consolidado 2026-11-11)

Fonte: `.i18n-queue/HELP_CANDIDATES.md` (i18n-help-ptbr), revisado e aprovado pelo lead.
Estes termos NÃO estão na tabela principal acima — são o vocabulário dos guias
(`resources/help/pt_BR/**`) e das telas Vue correspondentes (receiving/sorting/orders).
O copiloto DEVE reutilizar exatamente estas escolhas nos lotes de telas.

### Telas e fluxos

Receiving→Recebimento · Order Filling→Atendimento de pedidos · Shipping→Expedição ·
Inventory Movement→Movimentação de estoque · Pallet Management→Gerenciamento de pallets ·
Driver Portal→Portal do motorista · Setup (menu)→Configurações · fill record→registro de atendimento.

### Status de pedido (UI de orders/filling — alinhar com os guias)

New Order→Novo pedido · Ready to Fill→Pronto para atendimento · Filling→Em atendimento ·
Filled→Atendido · Ready to Ship→Pronto para expedição · Shipped→Expedido · Delivered→Entregue ·
Completed→Concluído · Closed - Unfulfilled→Encerrado — não atendido ("encerrado" evita confundir
com recusa de oferta) · Unfulfilled (verbo "close as Unfulfilled")→Não atendida.

### Status de oferta (donation offers)

Offered→Ofertada · Pending Arrival→Aguardando chegada · Received→Recebida · Refused→Recusada ·
Diverted→Redirecionada · Cancelled→Cancelada · Match to Arrival→Vincular à chegada · overdue→atrasada.

### Receiving/triagem/estoque

Box→Caixa · Bag→Saco · Tote→Tote (mantido; evita colisão com Caixa) · Gaylord→Gaylord (mantido) ·
Loose→Solto · Semi→Carreta · Box Truck→Caminhão baú · Personal Vehicle→Veículo próprio ·
Trailer→Reboque · Delivery Truck→Caminhão de entrega · shipment→remessa · carrier→transportadora ·
disposition→destinação (evita falso cognato) · Usable→Utilizável · Outdated→Vencido · Trash→Descarte ·
Divert→Redirecionar · Hold (pallet kind H)→Retenção · Quarantine (Q)→Quarentena ·
Warehouse (pallet kind W)→Armazenagem · condemned→inutilizado · seal/unseal/re-seal→lacrado/deslacr/relacrar ·
stage→preparar · shrinkage→Quebra · ledger→ledger (mantido; alt. "kardex") · Expires→Validade ·
Quick-Sort Candidate→Candidato à triagem rápida · sort hold→espera de numeração (sort hold) ·
Donor Unknown/unknown donor (dado semeado)→mantido em inglês, explicação traduzida ("doador desconhecido") ·
"GENERIC ITEM"→verbatim (linha semeada).

### Pedidos/atendimento/expedição

Start/Complete Filling→Iniciar/Concluir atendimento · Pick:→Separar: · Qty to Pick→Qtd. a separar ·
Review Allocation→Revisar alocação · Need level: Critical/Moderate/Low→Nível de necessidade: Crítico/Moderado/Baixo ·
Needed By Date→Data desejada · Any Day→Qualquer dia · Mark Shipped→Marcar como expedido ·
Shipping Label→Etiqueta de expedição · Retry/Retry All→Repetir/Repetir todas.

### Decisões do lead sobre as dúvidas dos candidatos

1. **Box/Case → "caixa"** (colapso aceito): "Case Qty" → **"Qtd. por caixa"** (unificado com o attribute
   `case_qty` do validation.php; o items.md foi ajustado de "Qtd. na caixa"). Se a operação distinguir
   Case de Box, revisitar.
2. **Stack → "Nível"**: nota de incerteza mantida (validar com a operação).
3. **Títulos "Guia de X"** nos PDFs; heading da página sem sufixo (wiring já em 4618bda).
4. **"Unknown Donor"** (registro semeado) → verbatim na UI, com texto explicativo traduzido ao redor.

## Consolidação final da fase (lotes 6-7 + final, 2026-11-11)

Vocabulário dos últimos lotes (admin/kiosk/impressoras/orders/auth), revisado pelo lead:

**Site (da impressora)→Local** (evita colisão com unidades de medida; o "site" do banner de manutenção é website e fica "site") · kiosk→quiosque · Withdraw→Retirar · Acknowledge→Ciente · Ready for Review→Pronta para revisão · Feature→Funcionalidade · warehouse→armazém · pairing→pareamento · recovery key→chave de recuperação · warehouse key→chave do armazém · Roll back→Reverter · Guest→Visitante · Emergency Roster→Lista de emergência · Needed But Not in Catalog→Necessitados fora do catálogo · Offline Order Form→Formulário de pedido offline · Close Out→Encerrar · Daily Close-Out→Fechamento diário · Seal & Place→Lacrar e posicionar · Unseal→Deslacrar · Set aside — damaged?→Apartar — danificado? · committing→Aplicando… · updated→Atualizado às · saved→Salvo às {placeholder} · Trainee→Treinando · Fill Rate→Taxa de atendimento · Cut at Allocation→Cortado na alocação · Bill of Lading (BOL)→Conhecimento de embarque (BOL) · Stock on Hand→Estoque disponível · Current Pipeline→Fluxo atual.

Mantidos (produto/infra): Backup, recovery (contexto de backup), heartbeat, RI Launcher, provisioner, updater, R Station, RI Print Server, Geocodio, Open Food Facts.

Status de pedido/oferta, receiving/triagem e termos de help: ver a seção "Termos dos help guides" acima (reutilizados nos lotes de telas).

Dívidas documentadas da fase (todas não bloqueantes): relatório completo em `I18N_COVERAGE_REPORT.md` (raiz), seção "Dívidas conhecidas" — pluralização, nó com `>` em atributo, literais após chain, cleanup --apply proibido, incertezas Stack/Box-Case. **Resolvidas na sessão de 2026-11-12**: statusLabels do UserAdminController e mensagens do fluxo de updates (Lote A, server-side, `lang/{en,pt_BR}/users.php` + `updates.php`), errors/503 + expired-verification-link (Lote B), e o wiring dos `__()` dos blades para `lang/*.php` (bug de chave crua nos relatórios; gerador `dev/scripts/i18n-lang-from-auto.cjs`). **Nova dívida**: literais `Yes`/`No`/`Never` no CSV export do UserAdminController (EN fixo).

## Sessão 2026-11-12 — máquina original (i18n retomada)

- **Ambiente reconstruído nesta máquina**: PHP 8.4.27 (`%LOCALAPPDATA%\Programs\php84` + `composer.phar`), cliente MariaDB 11.8.2 com `mariadb-dump` (`%LOCALAPPDATA%\Programs\mariadb-client`), container `ri-test-mariadb` (mariadb:11, porta 3306, root sem senha), CLI parcheada validada 4/4 suítes a partir de `C:\projects\i18n-localizer\localizer` (clone @6d478b3 + patch). Ambos os dirs estão no PATH do **usuário** — mas processos filhos herdam o PATH do momento em que o DSH iniciou: prefixe `$env:PATH` antes de pest/pint/mariadb-dump.
- **Patch versionado regravado em UTF-8/LF** (era UTF-16LE — `git apply` não o lia; aplicar com `--exclude=package-lock.json`, o lock do clone diverge do upstream).
- **Bug corrigido**: os `__()` dos blades usavam 1º segmento CamelCase (`Commons.`/`Reports.`/`Errors.`) sem arquivo de lang correspondente — os relatórios renderizavam chave crua em pt-BR (o tradutor PHP nunca leu os JSONs auto). Chaves dos blades normalizadas para minúsculas + gerador `dev/scripts/i18n-lang-from-auto.cjs` (+ overlay `i18n-lang-extra.json`). **NUNCA criar arquivos de lang CamelCase**: colidem com os minúsculos em filesystem case-insensitive (Reports.php == reports.php no Windows).
