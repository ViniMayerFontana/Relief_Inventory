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

## Tiles/breadcrumbs de menu (dado semeado — camada de apresentação, 2026-11-18)

`menu_items.link_text` e `pages.menu_title` ficam em inglês no banco (compatibilidade upstream); a tradução é feita na apresentação por `App\Support\MenuText` via `lang/pt_BR/menu.php` (chave = Str::slug do texto EN; texto sem chave renderiza em inglês). Tile → Exibir como: Shipping→Expedição · Donation Sorting→Triagem de doações · Order Entry→Entrada de pedidos · Order Filling→Atendimento de pedidos · Inventory Movement→Movimentação de estoque · Receiving→Recebimento · Sign-in Kiosk→Quiosque de acesso · Training Warehouse→Armazém de treinamento · Instance Admin→Administração da instância · Warehouse Dashboard→Painel do armazém · Situation Report→Relatório de situação · Partner Report→Relatório de parceiros · Driver Portal→Portal do motorista · Print Queue→Fila de impressão · Return→Voltar · Help→Ajuda (lista completa no próprio menu.php).

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

## Sessão 2026-11-17 — Lote Shipping + Layout (aprovado pelo lead)

**Novos termos (headers de seção da Expedição, plural):** Filled — Ready to Assign a Driver→Atendidos — aguardando atribuição de motorista · Ready to Ship (seção)→Prontos para expedição · Shipped (seção)→Expedidos · Delivered — Pending Review→Entregues — aguardando conferência · Delivered — Waiting on BOL→Entregues — aguardando BOL · Recently Completed→Concluídos recentemente · colunas Delivered/Rejected→Entregue/Rejeitado · Reject (botão)→Rejeitar. **Layout:** Log Out→Sair · Profile→Perfil · About→Sobre · Notifications→Notificações · Switch User→Trocar usuário · Invitations→Convites · Who's In The Building→Quem está no prédio · PIN Login on This Device→Login por PIN neste dispositivo · Relief Inventory Dashboard→Painel do Relief Inventory · Training warehouse — everything here is practice data.→Armazém de treinamento — tudo aqui é dado de prática · Set up your recovery key.→Configure sua chave de recuperação. · Confirm your recovery key is stored.→Confirme que sua chave de recuperação está guardada. · Open Instance Admin→Abrir Administração da Instância · Give a driver their phone number + PIN so they can sign into→Forneça ao motorista o número de telefone + PIN para que ele acesse · back-links ← Back to X→← Voltar para X (Receiving→Recebimento, All Orders→Todos os pedidos, All Sessions→Todas as sessões) · RIForm Save→Salvar · Mark all read→Marcar todas como lidas · No notifications yet.→Nenhuma notificação ainda. · dias abreviados Mon/Tue/Wed/Thu/Fri/Sat/Sun→Seg/Ter/Qua/Qui/Sex/Sáb/Dom · {p0}d/h ago→{p0} d/h atrás · Bag/Bags→Saco/Sacos · Manifest→Manifesto · Reset→Redefinir · Maintenance→Manutenção.

**Headers com "(" final**: chaves de seção terminam em " (" (lead antes de `{{ }}`) — o replacer remonta `$t('lead'){{ expr }})`. Não "corrigir" a chave removendo o parêntese.

**Verbatims novos (nunca traduzir):** nomes de browser/OS (Android, Chrome, Edge, Firefox, Opera, Safari, Linux, Windows, Windows 10, XMLHttpRequest, Unknown OS? não — traduzido "Sistema desconhecido"), `Commons.text.enter` = "Enter" (tecla), `Layouts.text.fullroute_is_placeholder` (vem de console.log), `UserAgent.text.safari_17_5_on` / `Bootstrap.text.unauthenticated` / `Realtime.text.printed_failed` (extraídos de COMENTÁRIOS), `DesignPolls.DeliveryDays.Days.text.can_accept_tue_wed` (string COMPUTADA em days.js — dias variam).

**Patches CLI round 4** (cumulativo versionado: `.i18n-cache/cli-patches/core-round4-cumulative.patch`; regenerar com `git -C <clone> diff --output=...`): (1) `hasBalancedDelimiters` aceita UM "(" final (lead de header); (2) regra 11 do css: cor só como segmento pós-hífen ("Delivered" ≠ css); (3) `isSpreadsheetReference` sem /i ("Rejected" ≠ R1C1); (4) combinador "+" só adjacente ("number + PIN" ≠ css; > e ~ seguem com espaços).

**Dívidas desta sessão (não bloqueantes):** (a) replacer limitação do `>` em atributo atingiu "Mark all read" (v-if `unreadCount > 0`) e "Invitations ({{n}})" ×2 (v-if `pendingInvitations > 0`) no AuthenticatedLayout — round 3.2 (parser com state-machine); (b) extractor rejeitou por paridade de aspas a prosa "Without it, an automatic backup can't restore the warehouses' encrypted settings after a disaster." (apóstrofo final em "warehouses'") — linha 61 do layout segue EN; (c) breadcrumb "→ Shipping" e tiles do dashboard vêm de `menu_items.link_text` (BANCO, via `MenuItem::getBreadcrumb`) — pendente decisão lead/usuário: seed pt-BR vs. camada de apresentação.

## Sessão 2026-11-17 — Lote 2 (residuais) — aprovado pelo lead

**Trocas:** 58 em 12 arquivos (PalletManagement 7, Receiving 7, PalletLocation 7, DonationOffers 8, InstanceAdmin 7, Forms 5, OrderEntry 6, RIForm 4, DonationSorting 4, BuildingSafety 1, FormSubmissions 1, Training 1). Novos termos: Required→Obrigatório · Offered→Ofertada · Received→Recebida · Paired→Pareado · Adjust inventory→Ajustar estoque · Record Adjustment (→Registrar ajuste ( · Maintenance→Manutenção · Manifest→Manifesto · back-links ← Back to X→← Voltar para X (Forms→Formulários) · ← All Orders→← Todos os pedidos · ← All Sessions→← Todas as sessões · Cancel Changes→Cancelar alterações · Keep Record→Manter registro · Confirm Delete — cannot be undone→Confirmar exclusão — não pode ser desfeito · Pallet Management→Gerenciamento de pallets (Head) · Receiving→Recebimento (Head) · Off = just collect the answers, no decision needed.→Desativado = apenas coleta as respostas, sem necessidade de decisão. · none (reached by the shared address)→nenhum (usa o endereço compartilhado) · Not readable here: copy it from the server's backup folder (→Não legível aqui: copie da pasta de backups do servidor ( · tap-your-name (VERBATIM) + "login for trainees…"→"Login por toque no nome para os treinandos — sem senha — …" (padrão PIN/treinamento do lead).

**Patches CLI round 4.5/4.6** (cumulativo regenerado: `.i18n-cache/cli-patches/core-round4-cumulative.patch`):
- **4.5 (CRÍTICO)** `findOuterTemplate` mascara comentários HTML antes do scan — comentários com `<template>` literal faziam o par externo ser detectado ERRADO e o corpo real do template ficava fora de TODOS os passes (RIForm era o único arquivo afetado no repo; conferência automática: 1 divergência em 184 .vue, corrigida).
- 4.6 guarda de prosa no `isCodeContent` (≥5 palavras sem estrutura JS não é código); attrRegex com pairing de aspas por classe (apóstrofo em valor); entidades &larr;/&rarr;/&harr;/&middot;.

**Dívidas round 3.2 registradas (lead: NÃO contornar à mão — guardrail 2):** literais em bindings ternários `:title="cond ? 'X' : ''"` (PalletLocation :697/:698); "Mark all read" e "Invitations ({{n}})" ×2 no AuthenticatedLayout (v-if com `>`); layout :61 "Without it, an automatic backup…" (paridade de apóstrofos no extractor); breadcrumb `menu_items.link_text` do banco.

## Sessão 2026-11-18 — Round 3.2 (aprovado e executado)

**Patches CLI round 3.2** (cumulativo regenerado: `.i18n-cache/cli-patches/core-round4-cumulative.patch`, 108.951 bytes, 9/9 probes):
- Máscara state-machine de `<`/`>` dentro de valores de atributo no `replaceInTemplate` (sentinels \u0005/\u0006 1:1, restaurados no fim) — resolve o "nó engolido por `>` em v-if".
- Pass 6 `boundTernaryRegex`: literais UI em bindings ternários `:title/:placeholder/:aria-label/:label/:alt` (guards: sem `===`/`!==`, sem args de $t(), sem key-shaped). **Armadilha registrada: regex LITERAL não processa `\\s` como `\s`** — escrever `/\s/`, não `/\\s/`.
- `hasBalancedDelimiters`: apóstrofo de possessivo plural ("warehouses'") não conta como aspa; regra simétrica de UM ")" inicial (cauda após `</code>`).

**Trocas aplicadas (replace: 20 em 8/8 arquivos):** AuthenticatedLayout 4 (Mark all read, Invitations ×2, Without it…) · PalletLocation 3 (Adjust inventory + :title ×2) · OrderEntry 3 (← Back ×2, Saving…→Salvando…) · OrderFilling 5 (Partner→Parceiro ×3, ← Back, fully picked→totalmente separado) · TrainingLogin 2 (← Back, No team yet→Ainda sem equipe) · Unlock 1 · Training 1 (cauda "); os dados são mantidos até a redefinição.") · RIForm 1 (Back to List→Voltar à lista, via nova chave `Components.button.back_to_list` — o replacer só cai para Commons em textos curtos, então chaves para componentes precisam existir no namespace do componente).

**Chaves novas:** `Layouts.text.without_it_an_automatic` = "Sem isso, um backup automático não consegue restaurar as configurações criptografadas dos armazéns depois de um desastre." · `Pages.text.finish_or_clear_items` = "Conclua ou limpe os itens preparados para adicionar primeiro" · `Pages.text.finish_or_clear_adjustment` = "Conclua ou limpe o ajuste primeiro" · `Pages.text.larr_back` = "← Voltar" · `Pages.text.change_partner` = "Alterar parceiro" (registrada, injection futuro) · `Pages.Setup.text.its_data_is_kept` = "); os dados são mantidos até a redefinição." (lead "\\@" inicial incluído no valor, igual aos leads com "(").

**Status final:** 3093 chaves EN, pt_BR 2971 traduzidas (96%; 122 verbatims EN===pt; faltantes reais = 0). Conferência 4.5 re-executada: apenas RIForm divergia (corrigido). Breadcrumb do banco: o LEAD fará a tradução na camada de apresentação (MenuItem::getBreadcrumb / tiles) — copiloto só cria chaves se solicitado. Branch de commit do lead: `2-colors-implementation`.

## Sessão 2026-11-19 — Migração pt-BR dos dados semeados (Fases 1–3, aprovado pelo lead)

- **Formato aprovado:** [Híbrida] DDL fica no original (limpo do bloco EN); bloco EN vai para `database/migrations/disabled_en/backup_en_<tabela>.php` (não-executável: o glob do migrator é `glob($path.'/*_*.php')`, NÃO recursivo — disabled_en nunca carrega); nova migration `2026_11_19_HHMMSS_seed_<tabela>_pt_br.php` com down() específico (delete/update por chave técnica — NUNCA truncate). [DML pura] arquivo inteiro para disabled_en. [Load-bearing EN] (default warehouse, kiosk location, itemtype Unknown): EN permanece no original (down interno casa por nome) e a pt é update pontual por chave técnica com down restaurando EN literal.
- **Traduzidos:** presets do builder de formulários (label/help_text/options pt; key/type/target_field técnicos), uses de localização (Preparação / Armazenagem de longo prazo / Triagem), Guest Types (Manutenção/Reparo, FEMA mantido, Estadual), UnitsSeeder + units extras (só name: libra/onça/quilograma/grama/galão/unidade/desconhecida/caixa/saco/garrafão; abbreviation/type técnicos), Default Warehouse→Armazém Padrão, Main Location→Localização principal, itemtype Unknown→Desconhecido (sem referência por nome — grep), Partner Agency Intake→Cadastro de organização parceira (intro_text pt; perguntas herdam presets pt; slug técnico preservado — sem refs em código).
- **NÃO migrar (referenciado — guardrail):** statuses.name (= Transaction::STATUS_*), roles.name (RBAC), permissions.key/description (não exibida em UI), CategoriesSeeder + PackageTypesSeeder (importadores Flowtrac casam por nome EN), CSV seeders (fonte externa), WarehouseActivitySeeder (demo), Unknown Donor (verbatim), ItemFamily (nomenclatura de mercado Twin/Queen/King).
- **Menu:** NÃO migrar — MenuText (lang/pt_BR/menu.php por slug EN) já traduz link_text/menu_title na apresentação; wheres por link_text em migrations posteriores reforçam manter EN. Lacunas: menu_items.group_label não passa pelo MenuText (lead estende MenuController/menu.php); pages.text não existe no schema atual.
- **Novos arquivos:** 8 migrations 2026_11_19_000001–000008 + 5 backups em disabled_en + UnitsSeeder pt. php -l 17/17.
- **Reativação do EN NÃO é `migrate --path=database/migrations/disabled_en`** (os backups não são migrations executáveis e o padrão `*_*.php` os carregaria com erro fatal): restaurar os originais via git (histórico anterior aos moves) e remover as migrations pt 2026_11_19_*.
