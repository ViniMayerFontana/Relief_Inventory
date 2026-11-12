# Issues upstream — CLI `@ai-localizer/cli` v0.1.1

Limitações encontradas no piloto de i18n (2026-11-09) que devem ser reportadas ao repo
upstream **https://github.com/VenMail/localizer** (Apache-2.0). Cada seção abaixo tem o
**título em inglês pronto para colar no GitHub** e o **corpo em inglês** num bloco de
código (copiar literal). Ambiente comum a todas: `@ai-localizer/cli`/`@ai-localizer/core`
**v0.1.1**, Windows 11, Node v24.20.0, projeto Laravel 13 + Inertia 2 + Vue 3.5
(134 SFCs / 37 views Blade). Oferecemos contribuir com PR. O registro completo das
limitações no nosso repositório é `dev/notes/I18N_GLOSSARY.md` (seção "Limitações
conhecidas") — citar como anexo quando útil.

---

## Issue 1 (A) — VueReplacer / cobertura em componentes com slots

**Título (EN):**

> `VueReplacer stops at the first inner </template> — near-zero coverage on slot-based SFCs`

**Corpo (EN):**

````markdown
### Context

Laravel 13 + Inertia 2 + Vue 3.5 project (134 SFCs; most CRUD pages render a shared
form component through named slots — `#header`, `#listactions`, `#thead`, `#tbody`,
`#default`). Running the extract/replace pipeline against one pilot page.

### What happens

In `@ai-localizer/core` `src/i18n/lib/replacers/vueReplacer.js`, `replace()` isolates
the template with:

```js
const templateMatch = content.match(/(<template[^>]*>)([\s\S]*?)(<\/template>)/i);
```

The `[\s\S]*?` is **non-greedy**, so the match ends at the **first** `</template>` —
which in slot-based components is an inner slot template (`<template #header>...`),
not the component's own template block. Everything after it is never processed.

Note the asymmetry: **extraction scans the whole SFC** (we got keys for strings that
live inside slots — e.g. a field label inside `<template #default>`), so the key map
already contains the strings the replacer then never looks at in that region.

### Repro

```html
<template>
  <Head title="Item Category Entry" />
  <SomeForm
    title="Item Category Management"
    newrecordcaption="Add Category">
    <template #listactions>
      <input placeholder="Search by Category Name..." />
    </template>
    <template #default>
      <div class="ri_fieldlabel">Category Name:</div>
    </template>
  </SomeForm>
</template>
```

`ai-localize extract` → `ai-localize replace`:

- Actual: only `<Head title="Item Category Entry" />` is replaced (it sits before the
  first inner `</template>`). 1 of 5 extracted strings rewritten; the other 4 —
  including `title="Item Category Management"` and `placeholder="Search by Category
  Name..."`, whose keys ARE in the base locale — stay hard-coded.
- Expected: the whole outer template block is processed (match the outermost
  `</template>`, or parse top-level SFC blocks properly).

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1, Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 2 (B) — Blade rewriter sem alias de namespace `Commons`

**Título (EN):**

> `Blade rewriter misses short texts: no Commons namespace alias in its key map`

**Corpo (EN):**

````markdown
### Context

Laravel 13 + Inertia 2 + Vue 3.5 project; piloting the pipeline on Blade views
(`resources/views/**`).

### What happens

`extract` routes short texts (≤ 2 words, ≤ 24 chars, no sentence punctuation) into a
`Commons` namespace. The Vue/JS replacement engine (`src/i18n/replace-i18n.js`,
`buildKeyMap()`) adds a `Commons|kind|text` alias (plus a `text`-kind fallback), so
those keys match from any file.

The Blade rewriter (`src/i18n/rewrite-i18n-blade.js`, `buildKeyMapFromTranslations()`)
registers **only the literal tree path** — no `Commons` alias, no kind fallback. Any
Blade string short enough to land in `Commons` therefore never matches its own
file-derived namespace.

### Repro

`resources/views/reports/pallet.blade.php` contains `<title>Pallet Report</title>`:

- extract writes the key as `Commons.text.pallet_report` (correct per the short-text rule);
- the rewriter looks up `Reports.Pallet|text|Pallet Report` (namespace derived from the
  file path) → miss → file unchanged (0 replacements), while longer texts in the same
  run (e.g. an error-page paragraph) are replaced fine.

### Expected

The Blade key map mirrors the Vue/JS behavior: `Commons` alias + `text`-kind fallback.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1, Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 3 (D) — inconsistência de kind no `<h1>` de Blade

**Título (EN):**

> `Blade: <h1> extracted with kind "text" but replaced with kind "heading" — headings are never substituted`

**Corpo (EN):**

````markdown
### What happens

In the Blade rewriter (`src/i18n/rewrite-i18n-blade.js`), `inferKindFromTagName()`
maps `h1`–`h6` to kind `heading`. But the extraction phase registered our `<h1>`
string under kind `text` — the base locale contains
`Errors.TurnstileMisconfigured.text.this_page_isn_t` for
`<h1>This page isn't set up yet</h1>`.

Replacement then builds `ns|heading|This page isn't set up yet`, which does not exist
in the key map (only `ns|text|...` does) → the heading is never replaced, even though
its key is present in the base locale.

### Repro

1. `extract` on a view with `<h1>This page isn't set up yet</h1>` → key written under
   `...text.this_page_isn_t`.
2. `replace` (Blade backend) → `<h1>` line unchanged; neighboring `<p>`/`<strong>`
   lines (kind `text`) are replaced.

### Expected

Consistent kind inference between the two phases (either the extractor tags headings
as `heading`, or the Blade key map adds a `heading`→`text` fallback the way
`replace-i18n.js` does for the Vue/JS path).

### Note

No retranslation needed once fixed: the keys are already in the base locale under
`text`.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1, Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 4 — validators ausentes no caminho Blade (falso positivo de comando)

**Título (EN):**

> `Blade extract/replace lack code validation — shell commands become translation keys`

**Corpo (EN):**

````markdown
### What happens

The Blade phases validate with ignore patterns only (`shouldIgnoreText`); the
validators used by the Vue/JS path (`src/i18n/lib/validators`) are not applied. In our
pilot, the extractor accepted the shell command `docker compose up -d` inside
`<pre>docker compose up -d</pre>` and the rewriter then produced:

```blade
<pre>{{ __("Errors.TurnstileMisconfigured.text.docker_compose_up_d") }}</pre>
```

— a shell command became a translation key.

Related observation: text fragments adjacent to inline tags in paragraphs containing
`<code>` (e.g. `— set`, `; then run:`, `, and set both`) are extracted as standalone
keys, but their parent paragraphs are skipped by the rewriter (tags inside), so those
fragments can never be rendered in context.

### Expected

Apply `validateText`/code validation to the Blade extract and replace phases — at
minimum skip `<pre>` content and command/config-looking strings. For fragments
adjacent to inline elements, either skip them or make the rewriter handle the parent
paragraph.

### Workaround used

Human review of the replace diff per batch + verbatim answers (translation value ==
source string) for false-positive keys.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1, Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 5 — divergência init/config (`localeLayout` vs `layout`)

**Título (EN):**

> `` `init` writes `localeLayout` but the core reads `layout` — init's layout choice is silently ignored ``

**Corpo (EN):**

````markdown
### What happens

`@ai-localizer/cli` `src/commands/init.js` writes the chosen layout as
`"localeLayout": <single|grouped>` into `package.json#aiI18n`. But
`@ai-localizer/core` `src/i18n/lib/projectConfig.js` → `getLocaleLayout()` reads
`cfg.layout` only (falling back to framework heuristics).

Consequence: the layout chosen at init is never honored. Laravel projects happen to
resolve `grouped` anyway (heuristic), but a non-Laravel project that chose `grouped`
silently gets `single`, and any explicit choice is dropped.

### Repro

```bash
ai-localize init --source-locale=en --locales=en,fr   # non-Laravel project
# package.json#aiI18n now has "localeLayout": "single" (or grouped)
# core resolves layout from the heuristic, not from this key
```

Renaming the key to `"layout"` in `package.json#aiI18n` makes the core honor it.

### Expected

`init` writes `layout` (and/or `getLocaleLayout()` reads both keys for backward
compatibility). We currently keep both keys in our `package.json#aiI18n` to be safe.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1, Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 6 — extract registra VALUE de select como chave de tradução

**Título (EN):**

> `Extract turns select option values into translation keys — risks rewriting value: 'x' into value: t('...')`

**Corpo (EN):**

````markdown
### What happens

In a Vue SFC, an inline options array like

```js
const typeOptions = [
  { value: 'weight', label: 'Weight' },
  { value: 'other',  label: 'Other'  },
];
```

gets its option VALUE (`'other'`, a machine identifier persisted to the database via
`v-model`) extracted as a translatable string — it landed in the base locale as
`Commons.text.other: "other"`, while the label correctly became
`Commons.text.other_2: "Other"`.

The replace phase did not rewrite it in our run, but the key map contains
`Commons|text|other`, so a script-side string-literal replacement pass that matches
object property values could rewrite `value: 'other'` into `value: t('Commons.text.other')`
— which would silently change the data written by `v-model` and break stored records.
This makes every `extract` run on a codebase with inline option arrays a latent
data-corruption risk, not just a cosmetic false positive.

### Expected

Exclude string literals assigned to common value-like property names
(`value`, `id`, `key`, `slug`, `type`?) from extraction — or apply the code validators
(`validateText`) to script object-literal property values, the same way the Blade path
lacks validators (see our earlier report).

### Workaround used

Verbatim translation for the false-positive key (translation value == source string)
and per-batch diff review.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1 (patched replacers; extractor unmodified
from HEAD 6d478b3), Windows 11, Node v24.20.0, Laravel 13 + Inertia 2 + Vue 3.5.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 7 — cleanup varre só o srcRoot: chaves usadas por Blade aparecem como "unused"

**Título (EN):**

> `Cleanup usage scan only covers srcRoot — keys referenced from Blade views are flagged unused and would be deleted`

**Corpo (EN):**

````markdown
### What happens

`cleanup-i18n-unused.js` builds its "key usage" index by scanning the project's
`srcRoot` (for Laravel: `resources/js`, 168 files in our project). Keys referenced from
Blade templates (`resources/views/**`) via `{{ __("Errors.TurnstileMisconfigured.text.this_page_isn_t") }}`
are therefore reported as unused.

In our run, 10 of 22 keys were flagged — all nine Blade-referenced keys (an error page
and a report title) plus one false-positive extract key. Running the suggested
`cleanup --apply` would have deleted the locale keys for a live error page, silently
reverting it to English (and `__()` would fall back to returning the key itself).

### Expected

The usage scan should include the Blade views root (`resources/views`) for Laravel
projects — the rewrite phase already knows this path (`rewrite-i18n-blade.js` hardcodes
it), so the cleanup phase can reuse the same resolution. At minimum, `--apply` should
refuse to delete keys whose namespace matches a Blade file layout when Blade is a
detected backend.

### Workaround used

Never run `cleanup --apply` on this project; treat the report as noise.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1 (HEAD 6d478b3, cleanup unmodified),
Windows 11, Node v24.20.0, Laravel 13 + Inertia 2 + Vue 3.5.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 8 — Vue mustache pass replaces only the FIRST string literal in an expression

**Título (EN):**

> `VueReplacer mustache pass handles one string literal per {{ }} — ternary fallback strings are never replaced`

**Corpo (EN):**

````markdown
### What happens

In `@ai-localizer/core` `src/i18n/lib/replacers/vueReplacer.js`, pass 3 ("String literals
inside {{ }} expressions") matches with

```js
const mustacheRegex = /(\{\{[^}]*?)(['"])([^'"]{3,200})\2([^}]*?\}\})/g;
```

The whole `{{ ... }}` region is consumed by a single match anchored on the FIRST quoted
string, so when the lookup succeeds the replacement is applied — but any other string
literal inside the same expression is never examined. When the first lookup fails, the
callback returns the match unchanged and later literals are skipped too.

Repro (all strings below had keys present in the base locale):

```html
<button ...>{{ confirmingDelete ? 'Confirm Delete — cannot be undone' : 'Delete' }}</button>
```

- Actual: `Confirm Delete — cannot be undone` → `$t('Pages.button.confirm_delete_cannot_be')`;
  `Delete` stays hard-coded even though `Commons.button.delete` exists.
- Expected: every string literal in the expression is looked up independently.

Related asymmetry: extraction registers only some of the literals of the same expression
(from `{{ record.requires_approval ? 'Required' : 'None' }}` it extracted `None` but not
`Required`), so the ternary pair cannot be fully covered even after a fix on the replace
side alone.

### Expected

Iterate over string literals within the mustache expression instead of one match per
expression; and align extraction so all literals of an expression are registered.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1 (patched template-block finder; the
mustache pass is unmodified from HEAD 6d478b3), Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 9 — extract turns script array literals (incl. RBAC role names) into translation keys

**Título (EN):**

> `Extract registers technical string arrays (e.g. RBAC role names) from scripts as translation keys`

**Corpo (EN):**

````markdown
### What happens

The extractor scans `<script>` string literals and registers keys for values that are
program identifiers, not UI copy. Repro from a real SFC:

```js
const STAFF_ROLE_NAMES = ['Administrator', 'Sorting and Inventory', 'Office'];
```

→ base locale gains `Commons.text.administrator`, `Commons.text.office`,
`Commons.text.sorting_and_inventory`.

These are RBAC role names persisted in the database and matched with
`whereIn('name', ...)` server-side. The key map now offers a translation key for
every one of them: a future script-side replacement pass (or an agent translating
the locale files naively) can turn `STAFF_ROLE_NAMES` into translated role names and
break every `role.name` comparison against the database. The replace phase did not
inject them in our run (the literals sit in positions the script replacer skips), but
the locale files actively invite the mistake.

### Expected

Skip string literals assigned to ALL_CAPS / SCREAMING_SNAKE constant arrays, or apply
the code validators (reject values that match existing DB-identifier conventions), or
at minimum register such keys under a "technical" namespace that `translate plan`
excludes by default.

### Workaround used

Verbatim answers (translation value == source string) for the role-name keys.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1 (HEAD 6d478b3, extractor unmodified),
Windows 11, Node v24.20.0, Laravel 13 + Inertia 2 + Vue 3.5.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 10 — extract registers strings from script comments

**Título (EN):**

> `Extract picks up quoted strings inside script comments as translation keys`

**Corpo (EN):**

````markdown
### What happens

Quoted phrases inside `//` / `/* */` script comments become translation keys. Repro
(real SFC comments):

- a comment reading `... the same "Any Day" pattern OrderEntry.vue's delivery-day chips
  use ...` produced `Commons.text.any_day: "Any Day"`;
- a comment reading `... what the "no override" (below) falls back to ...` produced
  `Commons.text.no_override: "no override"`.

These keys reference nothing and never render; worse, they pollute `translate plan`
(human/AI translators are asked to "translate" comment fragments) and, if a matching
string ever appears in real UI, the comment-derived key shadows intent.

### Expected

Strip comments before scanning script string literals (the template side already
ignores `<!-- -->` blocks).

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1 (HEAD 6d478b3), Windows 11,
Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Issue 11 — VueReplacer processes only the FIRST <script> block of an SFC

**Título (EN):**

> `VueReplacer ignores a second <script> block — Options-API sections are never rewritten`

**Corpo (EN):**

````markdown
### What happens

`VueReplacer.replace()` locates the script with a non-greedy single match:

```js
const scriptMatch = modified.match(/(<script[^>]*>)([\s\S]*?)(<\/script>)/i);
```

An SFC mixing `<script setup>` with a plain `<script>` (Options API) — which is valid
and common for pages that keep state in `data()`/`methods` — has only its FIRST script
block processed. In our project the second block holds user-facing fallback strings
(error messages, action button labels) that extraction DID register as keys, yet the
replacer never touches: extract covered 100% of the SFC, replace skipped the whole
Options-API block (0 injections there, while the template block was fully rewritten).

Note the asymmetry with the template fix from our earlier report (outermost
`</template>`): the same nested-block reasoning applies to `<script>`.

### Expected

Process every top-level `<script>` block (or, at minimum, all blocks before
`</template>`), keeping the module-idempotency guards.

### Environment

`@ai-localizer/cli` / `@ai-localizer/core` v0.1.1 (patched template-block finder; the
script pass is unmodified from HEAD 6d478b3), Windows 11, Node v24.20.0.

Happy to contribute a PR (Apache-2.0).
````

---

## Status de abertura (2026-11-12 — publicadas via API por @ViniMayerFontana)

Todas as 11 issues foram abertas no repo upstream (github.com/VenMail/localizer):

- [x] Issue 1 (A) — VueReplacer / slots → [#2](https://github.com/VenMail/localizer/issues/2)
- [x] Issue 2 (B) — Commons alias no Blade → [#3](https://github.com/VenMail/localizer/issues/3)
- [x] Issue 3 (D) — kind heading/text → [#4](https://github.com/VenMail/localizer/issues/4)
- [x] Issue 4 — validators Blade → [#5](https://github.com/VenMail/localizer/issues/5)
- [x] Issue 5 — init `localeLayout` vs `layout` → [#6](https://github.com/VenMail/localizer/issues/6)
- [x] Issue 6 — extract pega VALUE de select → [#7](https://github.com/VenMail/localizer/issues/7)
- [x] Issue 7 — cleanup scan não cobre Blade → [#8](https://github.com/VenMail/localizer/issues/8)
- [x] Issue 8 — mustache: só a 1ª string do ternário → [#9](https://github.com/VenMail/localizer/issues/9)
- [x] Issue 9 — extract pega ROLE names de arrays → [#10](https://github.com/VenMail/localizer/issues/10)
- [x] Issue 10 — extract pega strings de comentários → [#11](https://github.com/VenMail/localizer/issues/11)
- [x] Issue 11 — segundo bloco <script> ignorado → [#12](https://github.com/VenMail/localizer/issues/12)
- Anexo `dev/notes/I18N_GLOSSARY.md` ("Limitações conhecidas") referenciado nos corpos quando útil.
