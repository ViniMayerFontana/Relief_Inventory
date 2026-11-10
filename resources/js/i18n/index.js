// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// Bridge between the calls the ai-localizer CLI injects and vue-i18n.
//
// - Templates: `$t(...)` comes from vue-i18n itself, installed globally in
//   app.js (globalInjection) — supports the named params the CLI bakes in
//   for strings that contain mustache expressions.
// - Scripts: the CLI injects `import { t } from '@/i18n'` — this module.
//
// Locale messages live in ./auto/<locale>/<group>.json ("grouped" layout,
// written by `ai-localize extract`; sync propagates keys to pt_BR).

import { computed } from 'vue';
import { createI18n } from 'vue-i18n';

const messages = {};
for (const [file, module] of Object.entries(import.meta.glob('./auto/*/*.json', { eager: true }))) {
    const match = file.match(/\.\/auto\/([^/]+)\/[^/]+\.json$/);
    if (!match) continue;
    messages[match[1]] = { ...(messages[match[1]] || {}), ...module.default };
}

export const i18n = createI18n({
    legacy: false,
    globalInjection: true,
    locale: 'en',
    fallbackLocale: 'en',
    messages,
});

export function setLocale(locale) {
    // Unknown locale (or no locale yet) keeps the fallback: 'en'.
    if (messages[locale]) i18n.global.locale.value = locale;
}

export function getLocale() {
    return i18n.global.locale.value;
}

// Script-side translation hook injected by ai-localizer (`import { t } from '@/i18n'`).
export function t(key, params) {
    return i18n.global.t(key, params ?? {});
}

export const locale = computed(() => i18n.global.locale.value);
