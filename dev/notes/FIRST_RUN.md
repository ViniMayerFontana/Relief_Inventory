# First-run setup

`App\Services\FirstRunService` backs the setup wizard and its CLI twins (`admin:bootstrap`, `setup:seed-essentials`, `setup:status`). An instance "needs setup" only while the `setup_state` latch is unset **and** no Administrator exists; the latch is what keeps a working instance from ever being offered to a stranger again. The wizard's single write is essentials + administrator + latch together. Optional demo data (`WarehouseActivitySeeder`) records `setup_state.demo_data_seeded_at`. A warehouse created later is set up through its setup code instead (`MULTI_WAREHOUSE_NOTES.md`), and that administrator is not an instance admin.

## Interface language (pt-BR)

To run an install in Brazilian Portuguese, set `APP_LOCALE=pt_BR` in the environment: `lang/pt_BR/` ships complete (validation, pagination, auth, passwords, mail) and the Vue side shares the locale through `HandleInertiaRequests` (fallback `en`). Existing English installs keep working untouched — removing `APP_LOCALE` or setting it to `en` reverts everything, including generated UI strings (`resources/js/i18n/auto/`, keyed from the pt-BR pilot). Report labels, e-mail bodies and PDF paper size follow the same locale. The demo seed (`WarehouseActivitySeeder`) is for demo instances only. Per-user language selection is a future idea (would need a `users.locale` column in the accounts schema).
