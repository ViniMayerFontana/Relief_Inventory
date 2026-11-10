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

## Checklist de abertura (para quem for colar)

- [ ] Issue 1 (A) — VueReplacer / slots
- [ ] Issue 2 (B) — Commons alias no Blade
- [ ] Issue 3 (D) — kind heading/text
- [ ] Issue 4 — validators Blade
- [ ] Issue 5 — init `localeLayout` vs `layout`
- Anexar/comentar `dev/notes/I18N_GLOSSARY.md` ("Limitações conhecidas") quando útil.
