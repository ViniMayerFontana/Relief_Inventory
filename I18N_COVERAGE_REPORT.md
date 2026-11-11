# RelatÃ³rio de cobertura i18n EN â†’ pt-BR â€” Relief Inventory

> Fase: branch `i18n-pt-br-pilot`. Gerado em 2026-11-11 pelo agente i18n-copilot-2 a partir do estado real da Ã¡rvore
> (apÃ³s todos os lotes da fase, incluindo o fechamento das 54 pÃ¡ginas restantes). Status por arquivo: **TRADUZIDA** = strings de UI extraÃ­das/injetadas pela CLI e traduzidas em pt_BR;
> **VERBATIM** = strings tÃ©cnicas intencionais em inglÃªs (papÃ©is, tokens, comandos, nomes de produto); **GAP** = limitaÃ§Ã£o conhecida da CLI
> documentada; **estrutural** = arquivo sem strings de UI prÃ³prias.

## Resumo

| SuperfÃ­cie | Arquivos | Com traduÃ§Ã£o | Sem strings / nÃ£o iniciada |
|---|---|---|---|
| PÃ¡ginas Vue (resources/js/Pages/**) | 88 | 87 | 1 estrutural (Help/Guide) |
| Componentes (resources/js/Components/**) | 39 | 23 | 16 sem strings extraÃ­veis |
| Blade (resources/views/**) | 37 | 29 | 8 estruturais/sem strings |

- Chaves de locale JS (resources/js/i18n/auto): **372 â†’ 2968** durante a fase; pt_BR **97%** traduzido, **0 faltantes reais** (101 chaves same-as-EN = verbatims intencionais).
- Todos os lotes passaram por: ensaio em cÃ³pia â†’ auditoria de guardrails â†’ replace real â†’ `php artisan view:cache` + gate `@vue/compiler-sfc` â†’ traduÃ§Ã£o (answers por mapa ENâ†’PT) â†’ `translate apply`/`sync`.
- CLI `@ai-localizer` parcheada em 4 rounds locais (core-round3.patch cumulativo, 201.618 bytes; suÃ­tes R2 23/23, R3 21/21, R3.1 40/40, Blade 10/10).

## PÃ¡ginas Vue (88)

| Arquivo | $t() | Status |
|---|---|---|
| resources/js/Pages/About.vue | 16 | TRADUZIDA (16 chamadas) |
| resources/js/Pages/Account/Invitations.vue | 13 | TRADUZIDA (13 chamadas) |
| resources/js/Pages/ActiveSessions.vue | 31 | TRADUZIDA (31 chamadas) |
| resources/js/Pages/AppAbout.vue | 18 | TRADUZIDA (18 chamadas) |
| resources/js/Pages/Auth/AcceptInvitation.vue | 6 | TRADUZIDA (6 chamadas) |
| resources/js/Pages/Auth/ChangePasswordRequired.vue | 5 | TRADUZIDA (5 chamadas) |
| resources/js/Pages/Auth/ChooseTrack.vue | 11 | TRADUZIDA (11 chamadas) |
| resources/js/Pages/Auth/ConfirmPassword.vue | 3 | TRADUZIDA (3 chamadas) |
| resources/js/Pages/Auth/ForgotPassword.vue | 3 | TRADUZIDA (3 chamadas) |
| resources/js/Pages/Auth/Login.vue | 8 | TRADUZIDA (8 chamadas) |
| resources/js/Pages/Auth/Register.vue | 4 | TRADUZIDA (4 chamadas) |
| resources/js/Pages/Auth/RegistrationPending.vue | 8 | TRADUZIDA (8 chamadas) |
| resources/js/Pages/Auth/ResetPassword.vue | 2 | TRADUZIDA (2 chamadas) |
| resources/js/Pages/Auth/TrainingLogin.vue | 18 | TRADUZIDA (18 chamadas) |
| resources/js/Pages/Auth/Unlock.vue | 15 | TRADUZIDA (15 chamadas) |
| resources/js/Pages/Auth/VerifyEmail.vue | 7 | TRADUZIDA (7 chamadas) |
| resources/js/Pages/BuildingSafety.vue | 14 | TRADUZIDA (14 chamadas) |
| resources/js/Pages/CartonCodes.vue | 20 | TRADUZIDA (20 chamadas) â€” gap conhecido: "Showing the newest {{ n }} of {{ total }}." cru (">" dentro de atributo quebra o textBetweenTags do replacer; a frase completa jÃ¡ existe traduzida em Pages.text.showing_the_newest_records) |
| resources/js/Pages/CategoryEntry.vue | 6 | TRADUZIDA (6 chamadas) |
| resources/js/Pages/ComingSoon.vue | 1 | TRADUZIDA (1 chamadas) |
| resources/js/Pages/Dashboard.vue | 1 | TRADUZIDA (1 chamadas) |
| resources/js/Pages/DesignVote.vue | 38 | TRADUZIDA (38 chamadas) |
| resources/js/Pages/Display/Stats.vue | 21 | TRADUZIDA (21 chamadas) |
| resources/js/Pages/DonationOffers.vue | 109 | TRADUZIDA (109 chamadas) |
| resources/js/Pages/DonationSorting.vue | 138 | TRADUZIDA (138 chamadas) |
| resources/js/Pages/DonorReport.vue | 57 | TRADUZIDA (57 chamadas) |
| resources/js/Pages/DriverPortal.vue | 35 | TRADUZIDA (35 chamadas) |
| resources/js/Pages/EmailSettings.vue | 47 | TRADUZIDA (47 chamadas) â€” gap conhecido: "Will use the one in the server .server .env" cru (literal apÃ³s chain nÃ£o Ã© extraÃ­do â€” limitaÃ§Ã£o do extractor; a irmÃ£ using_the_one_in estÃ¡ traduzida) |
| resources/js/Pages/FeedbackReports.vue | 55 | TRADUZIDA (55 chamadas) |
| resources/js/Pages/FlowReport.vue | 56 | TRADUZIDA (56 chamadas) |
| resources/js/Pages/Forms.vue | 63 | TRADUZIDA (63 chamadas) |
| resources/js/Pages/FormSubmissions.vue | 23 | TRADUZIDA (23 chamadas) |
| resources/js/Pages/Help/Guide.vue | 0 | estrutural â€” sem strings prÃ³prias (o conteÃºdo vem de resources/help, agente help-ptbr) |
| resources/js/Pages/Help/Index.vue | 9 | TRADUZIDA (9 chamadas) |
| resources/js/Pages/Imports.vue | 43 | TRADUZIDA (43 chamadas) |
| resources/js/Pages/InstanceAdmin.vue | 272 | TRADUZIDA (272 chamadas) |
| resources/js/Pages/InventoryReport.vue | 34 | TRADUZIDA (34 chamadas) |
| resources/js/Pages/ItemEntry.vue | 47 | TRADUZIDA (47 chamadas) â€” gap conhecido: fragmento "pallet stock entr{{ â€¦ }}" cru (nÃ³ com 2 mustaches â€” o trail "e quaisquer cÃ³digos de barrasâ€¦" estÃ¡ traduzido) |
| resources/js/Pages/Join.vue | 26 | TRADUZIDA (26 chamadas) |
| resources/js/Pages/KioskSettings.vue | 45 | TRADUZIDA (45 chamadas) |
| resources/js/Pages/LocationEntry.vue | 24 | TRADUZIDA (24 chamadas) |
| resources/js/Pages/MailingLabels.vue | 40 | TRADUZIDA (40 chamadas) |
| resources/js/Pages/OrderEntry.vue | 135 | TRADUZIDA (135 chamadas) |
| resources/js/Pages/OrderFilling.vue | 80 | TRADUZIDA (80 chamadas) |
| resources/js/Pages/OutstandingOrdersReport.vue | 24 | TRADUZIDA (24 chamadas) |
| resources/js/Pages/PackageTypes.vue | 10 | TRADUZIDA (10 chamadas) |
| resources/js/Pages/PalletLocation.vue | 129 | TRADUZIDA (129 chamadas) |
| resources/js/Pages/PalletManagement.vue | 34 | TRADUZIDA (34 chamadas) |
| resources/js/Pages/PartnerReport.vue | 52 | TRADUZIDA (52 chamadas) |
| resources/js/Pages/People.vue | 63 | TRADUZIDA (63 chamadas) |
| resources/js/Pages/PickPath.vue | 18 | TRADUZIDA (18 chamadas) |
| resources/js/Pages/PinLoginSettings.vue | 49 | TRADUZIDA (49 chamadas) |
| resources/js/Pages/PrinterManagement.vue | 36 | TRADUZIDA (36 chamadas) |
| resources/js/Pages/PrintQueue.vue | 48 | TRADUZIDA (48 chamadas) |
| resources/js/Pages/Profile/Edit.vue | 2 | TRADUZIDA (2 chamadas) |
| resources/js/Pages/Profile/Partials/DeleteUserForm.vue | 8 | TRADUZIDA (8 chamadas) |
| resources/js/Pages/Profile/Partials/UpdatePasswordForm.vue | 4 | TRADUZIDA (4 chamadas) |
| resources/js/Pages/Profile/Partials/UpdatePinForm.vue | 7 | TRADUZIDA (7 chamadas) |
| resources/js/Pages/Profile/Partials/UpdateProfileInformationForm.vue | 7 | TRADUZIDA (7 chamadas) |
| resources/js/Pages/PublicForm.vue | 9 | TRADUZIDA (9 chamadas) |
| resources/js/Pages/QRCodeTest.vue | 2 | TRADUZIDA (2 chamadas) |
| resources/js/Pages/Receiving.vue | 141 | TRADUZIDA (141 chamadas) |
| resources/js/Pages/RStationDevices.vue | 58 | TRADUZIDA (58 chamadas) |
| resources/js/Pages/RStationFirmware.vue | 52 | TRADUZIDA (52 chamadas) |
| resources/js/Pages/Setup/Activate.vue | 12 | TRADUZIDA (12 chamadas) |
| resources/js/Pages/Setup/DesignVotes.vue | 35 | TRADUZIDA (35 chamadas) |
| resources/js/Pages/Setup/FirstRun.vue | 30 | TRADUZIDA (30 chamadas) |
| resources/js/Pages/Setup/RestoreBackup.vue | 34 | TRADUZIDA (34 chamadas) |
| resources/js/Pages/Setup/Training.vue | 105 | TRADUZIDA (105 chamadas) |
| resources/js/Pages/Setup/TrainingProducts.vue | 40 | TRADUZIDA (40 chamadas) |
| resources/js/Pages/Setup/WarehouseRestore.vue | 5 | TRADUZIDA (5 chamadas) |
| resources/js/Pages/Shipping.vue | 102 | TRADUZIDA (102 chamadas) |
| resources/js/Pages/Signs.vue | 23 | TRADUZIDA (23 chamadas) |
| resources/js/Pages/SiteBanner.vue | 18 | TRADUZIDA (18 chamadas) |
| resources/js/Pages/SituationReport.vue | 24 | TRADUZIDA (24 chamadas) |
| resources/js/Pages/SortingAreaReport.vue | 18 | TRADUZIDA (18 chamadas) |
| resources/js/Pages/SystemAdmin.vue | 118 | TRADUZIDA (118 chamadas) |
| resources/js/Pages/TestingTools.vue | 84 | TRADUZIDA (84 chamadas) |
| resources/js/Pages/ThisDevice.vue | 34 | TRADUZIDA (34 chamadas) |
| resources/js/Pages/TrainingReport.vue | 23 | TRADUZIDA (23 chamadas) |
| resources/js/Pages/TrustConsole.vue | 86 | TRADUZIDA (86 chamadas) |
| resources/js/Pages/UnfulfilledRequestsReport.vue | 45 | TRADUZIDA (45 chamadas) |
| resources/js/Pages/Units.vue | 12 | TRADUZIDA (12 chamadas) |
| resources/js/Pages/Users.vue | 92 | TRADUZIDA (92 chamadas) â€” VERBATIMS intencionais: STAFF_ROLE_NAMES = ['Administrator', 'Sorting and Inventory', 'Office'] â€” nomes de papel = dados (guardrail 1, verificado) |
| resources/js/Pages/VolunteerKiosk.vue | 99 | TRADUZIDA (99 chamadas) |
| resources/js/Pages/WarehouseDashboard.vue | 29 | TRADUZIDA (29 chamadas) |
| resources/js/Pages/WarehouseSwitched.vue | 5 | TRADUZIDA (5 chamadas) |
| resources/js/Pages/Welcome.vue | 13 | TRADUZIDA (13 chamadas) |

### PÃ¡ginas traduzidas nesta fase (18, [histÃ³rico]): CategoryEntry, PackageTypes, Units, LocationEntry, Forms, People, Users, CartonCodes, ItemEntry, EmailSettings, SiteBanner, ActiveSessions, Imports (cura-pass); DonationSorting, Receiving, OrderFilling, PalletManagement, PalletLocation (task-9).
### Lote 6+7 desta fase (16): SystemAdmin, FeedbackReports, PrinterManagement, RStationDevices, RStationFirmware, KioskSettings, PinLoginSettings, ThisDevice, VolunteerKiosk, PrintQueue, InstanceAdmin, DonationOffers, DonorReport, FlowReport, OrderEntry, DesignVote.
### Lote final desta fase (54): About, Account/Invitations, AppAbout, Auth/* (11), BuildingSafety, ComingSoon, Dashboard, Display/Stats, DriverPortal, FormSubmissions, Help/Index, InventoryReport, Join, MailingLabels, OutstandingOrdersReport, PartnerReport, PickPath, Profile/* (4), PublicForm, QRCodeTest, Setup/* (7), Shipping, Signs, SituationReport, SortingAreaReport, TestingTools, TrainingReport, TrustConsole, UnfulfilledRequestsReport, WarehouseDashboard, WarehouseSwitched, Welcome. Help/Guide.vue Ã© estrutural (renderiza o Markdown de resources/help).

## Componentes (39)

| Arquivo | $t() | Status |
|---|---|---|
| resources/js/Components/AddressCorrectionCheck.vue | 8 | TRADUZIDO (8 chamadas) |
| resources/js/Components/Banner.vue | 4 | TRADUZIDO (4 chamadas) |
| resources/js/Components/ChartCanvas.vue | 1 | TRADUZIDO (1 chamadas) |
| resources/js/Components/Checkbox.vue | 0 | sem strings casÃ¡veis / prop-only |
| resources/js/Components/ChipSelect.vue | 0 | sem strings casÃ¡veis / prop-only |
| resources/js/Components/ComboBox.vue | 1 | TRADUZIDO (1 chamadas) |
| resources/js/Components/DangerButton.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/Dashboard/BarBreakdownCard.vue | 1 | TRADUZIDO (1 chamadas) |
| resources/js/Components/Dashboard/PeriodStatCard.vue | 5 | TRADUZIDO (5 chamadas) |
| resources/js/Components/Dashboard/TrendBadge.vue | 2 | TRADUZIDO (2 chamadas) |
| resources/js/Components/DeviceTypeIcon.vue | 2 | TRADUZIDO (2 chamadas) |
| resources/js/Components/Dropdown.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/DropdownLink.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/FeedbackReportCard.vue | 16 | TRADUZIDO (16 chamadas) |
| resources/js/Components/FeedbackReportModal.vue | 12 | TRADUZIDO (12 chamadas) |
| resources/js/Components/HelpLink.vue | 1 | TRADUZIDO (1 chamadas) |
| resources/js/Components/HelpPage.vue | 4 | TRADUZIDO (4 chamadas) |
| resources/js/Components/InputError.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/InputLabel.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/KioskEnableConfirmModal.vue | 6 | TRADUZIDO (6 chamadas) |
| resources/js/Components/Modal.vue | 0 | sem strings casÃ¡veis / prop-only |
| resources/js/Components/MultiSelect.vue | 0 | sem strings casÃ¡veis / prop-only |
| resources/js/Components/NavLink.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/NewItemModal.vue | 23 | TRADUZIDO (23 chamadas) |
| resources/js/Components/PrimaryButton.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/PrintMenu.vue | 12 | TRADUZIDO (12 chamadas) |
| resources/js/Components/PrintToast.vue | 4 | TRADUZIDO (4 chamadas) |
| resources/js/Components/QrScanner.vue | 7 | TRADUZIDO (7 chamadas) |
| resources/js/Components/ResponsiveNavLink.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/RIForm.vue | 2 | TRADUZIDO (2 chamadas) |
| resources/js/Components/RISubform.vue | 1 | TRADUZIDO (1 chamadas) |
| resources/js/Components/ScanButton.vue | 5 | TRADUZIDO (5 chamadas) |
| resources/js/Components/SearchSelect.vue | 5 | TRADUZIDO (5 chamadas) |
| resources/js/Components/SecondaryButton.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/TextArea.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/TextInput.vue | 0 | sem strings de UI (estrutural) |
| resources/js/Components/TileSelect.vue | 0 | sem strings casÃ¡veis / prop-only |
| resources/js/Components/UserInvitations.vue | 6 | TRADUZIDO (6 chamadas) |
| resources/js/Components/WebcamCapture.vue | 2 | TRADUZIDO (2 chamadas) |

## Blade (37)

| Arquivo | __()/@lang | Status |
|---|---|---|
| resources/views/app.blade.php | 0 | estrutural (sem UI text) |
| resources/views/emails/account-created.blade.php | 12 | TRADUZIDO (12) |
| resources/views/emails/feedback-report-status-updated.blade.php | 11 | TRADUZIDO (11) |
| resources/views/emails/feedback-report-submitted.blade.php | 11 | TRADUZIDO (11) |
| resources/views/emails/form-submission-notification.blade.php | 3 | TRADUZIDO (3) |
| resources/views/emails/membership-invitation.blade.php | 7 | TRADUZIDO (7) |
| resources/views/errors/503.blade.php | 0 | sem strings casÃ¡veis / dinÃ¢mico (prÃ³xima fase se houver texto) |
| resources/views/errors/expired-verification-link.blade.php | 0 | sem strings casÃ¡veis / dinÃ¢mico (prÃ³xima fase se houver texto) |
| resources/views/errors/turnstile-misconfigured.blade.php | 4 | TRADUZIDO (4) |
| resources/views/reports/bol.blade.php | 22 | TRADUZIDO (22) |
| resources/views/reports/donors.blade.php | 16 | TRADUZIDO (16) |
| resources/views/reports/flow.blade.php | 26 | TRADUZIDO (26) |
| resources/views/reports/help/all.blade.php | 2 | TRADUZIDO (2) |
| resources/views/reports/help/guide.blade.php | 0 | sem strings casÃ¡veis / dinÃ¢mico (prÃ³xima fase se houver texto) |
| resources/views/reports/help/layout.blade.php | 2 | TRADUZIDO (2) |
| resources/views/reports/inventory-labels.blade.php | 1 | TRADUZIDO (1) |
| resources/views/reports/inventory.blade.php | 14 | TRADUZIDO (14) |
| resources/views/reports/mailing_labels.blade.php | 2 | TRADUZIDO (2) |
| resources/views/reports/order-form.blade.php | 18 | TRADUZIDO (18) |
| resources/views/reports/orders.blade.php | 13 | TRADUZIDO (13) |
| resources/views/reports/pallet-batch.blade.php | 1 | TRADUZIDO (1) |
| resources/views/reports/pallet.blade.php | 1 | TRADUZIDO (1) |
| resources/views/reports/partials/inventory_label.blade.php | 0 | sem strings casÃ¡veis / dinÃ¢mico (prÃ³xima fase se houver texto) |
| resources/views/reports/partials/pallet_label_css.blade.php | 0 | estrutural (sem UI text) |
| resources/views/reports/partials/pallet_label.blade.php | 0 | sem strings casÃ¡veis / dinÃ¢mico (prÃ³xima fase se houver texto) |
| resources/views/reports/partners.blade.php | 16 | TRADUZIDO (16) |
| resources/views/reports/pick-sheets.blade.php | 11 | TRADUZIDO (11) |
| resources/views/reports/shipping-label.blade.php | 6 | TRADUZIDO (6) |
| resources/views/reports/sign.blade.php | 0 | sem strings casÃ¡veis / dinÃ¢mico (prÃ³xima fase se houver texto) |
| resources/views/reports/sitrep.blade.php | 32 | TRADUZIDO (32) |
| resources/views/reports/training/certificate.blade.php | 5 | TRADUZIDO (5) |
| resources/views/reports/training/report-cards.blade.php | 7 | TRADUZIDO (7) |
| resources/views/reports/training/setup-packet.blade.php | 23 | TRADUZIDO (23) |
| resources/views/reports/training/signup-poster.blade.php | 3 | TRADUZIDO (3) |
| resources/views/reports/training/spot-labels.blade.php | 1 | TRADUZIDO (1) |
| resources/views/reports/training/team-sheet.blade.php | 11 | TRADUZIDO (11) |
| resources/views/reports/unfulfilled.blade.php | 16 | TRADUZIDO (16) |

### Notas Blade
- 28 views de `resources/views/reports` traduzidos no task-8 (21 com injetaÃ§Ã£o + 7 sem strings casÃ¡veis); DocumentRegistry.php convertido a `HelpReportController::title($slug)` / `__('help.all_guides')`.
- 5 e-mails (resources/views/emails/**) com `__()` desde o task-4; errors/Turnstile no piloto; errors/503 e expired-verification-link ficaram para prÃ³xima fase.
- `resources/help/**` e `app/Support/HelpGuide.php` sÃ£o do agente i18n-help-ptbr (task-5) â€” fora do escopo deste relatÃ³rio.

## Locale Laravel/JS

- `lang/pt_BR`: validation, pagination, mail, help, reports.php (task-4) â€” pint PASS; espelhos em `lang/en`.
- Locale JS: `resources/js/i18n/auto/{en,pt_BR}/{commons,pages,views,components}.json` â€” 2968 chaves EN, pt_BR 0 faltantes reais.
- VERBATIMS intencionais (nunca traduzir): papÃ©is RBAC (Commons.text.administrator/office/sorting_and_inventory; STAFF_ROLE_NAMES intacto em Users.vue), valores de select/approval (other, none), Plus Code, ACS Item#, UPC, ETA, PIN, CSV headers de importaÃ§Ã£o (First Name, Last Nameâ€¦), docker compose (comando), R Station, RI Print Server, RI Emoji, Geocodio, Open Food Facts, Gaylord, Tote, fragmentos tÃ©cnicos (, email:, , help_text:, , down:, â€” commit, clear_{placeholder}).

## DÃ­vidas conhecidas (documentadas, nenhuma bloqueante)

1. **PluralizaÃ§Ã£o**: padrÃ£o "{p0} item(s)"/"linha(s)" â€” a API de plural do vue-i18n nÃ£o foi usada em nenhuma chave.
2. **NÃ³ com ">" em atributo** (replacer): CartonCodes "Showing the newest {{ n }} of {{ total }}." permanece cru; a frase completa jÃ¡ existe traduzida (`Pages.text.showing_the_newest_records`). Candidato a round 3.2 (parser de tags state-machine).
3. **Literais apÃ³s chain** (extractor): "Will use the one in the server .env" (EmailSettings) cru; a irmÃ£ `using_the_one_in` estÃ¡ traduzida.
4. **cleanup --apply PROIBIDO** (Issue 7 upstream â€” o cleanup varre sÃ³ resources/js e apagaria chaves de Blade).
5. **statusLabels do UserAdminController** (labels de status vindos do servidor para Users.vue) â€” adiado; quando feito, bloco prÃ³prio no padrÃ£o notifications.php (trans() server-side).
6. **UpdateSender** (PHP server-side, textos de e-mail/notificaÃ§Ã£o do remetente de updates) â€” server-side, fora da CLI; tratar como task-4 (trans() server-side) em lote prÃ³prio.
7. **errors/503 e expired-verification-link** (Blade) â€” prÃ³xima fase.
8. **Datas/horas** exibidas client-side via `toLocaleString` â€” navegador pt-BR formata corretamente; sem dÃ­vida.
9. **Incerteza de glossÃ¡rio**: Stack â†’ "NÃ­vel" (validar com a operaÃ§Ã£o se Ã© vertical ou fundo do rack); Box/Case â†’ "caixa" (colapso aceito).

## Infraestrutura deixada para as prÃ³ximas fases

- CLI parcheada (rounds 1â€“3.1d) com patch cumulativo restaurÃ¡vel: `.i18n-cache/cli-patches/core-round3.patch` sobre o HEAD 6d478b3 de VenMail/localizer + suÃ­tes de regressÃ£o (test-round2/3/31/blade.js).
- ExtraÃ§Ã£o/replace ESCOPADOS por arquivo (extract-i18n.js e replace-i18n.js aceitam lista de arquivos; rewrite-i18n-blade.js idem) â€” permite lotes por Ã¡rea sem contaminar o restante.
- Ignore file do projeto: `scripts/i18n-ignore-patterns.json` (exact: "download" â€” valor de estado).
- PadrÃ£o de traduÃ§Ã£o de lotes grandes: mapa ENâ†’PT + gerador que deriva answers.json do pending (imune a erro de chave, com verificaÃ§Ã£o de cobertura 100%).


