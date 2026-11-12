'use strict';
// Testes isolados do round 3 (validadores + trailing-text + chains + ||-literals).
const path = require('node:path');
const clone = path.join(process.env.TEMP, 'i18n-localizer', 'localizer', 'packages', 'core', 'src', 'i18n');
const v = require(path.join(clone, 'lib', 'validators', 'index.js'));
const { VueParser } = require(path.join(clone, 'lib', 'parsers', 'vueParser.js'));
const { VueReplacer } = require(path.join(clone, 'lib', 'replacers', 'vueReplacer.js'));
const { JsxReplacer } = require(path.join(clone, 'lib', 'replacers', 'jsxReplacer.js'));

let fails = 0;
const check = (name, ok) => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}`); if (!ok) fails++; };

// --- Validadores (4 gates do lote 4) ---
check(' Removing… agora passa', v.shouldTranslate('Removing…'));
check(' Moving... agora passa', v.shouldTranslate('Moving...'));
check(' UPC agora passa', v.shouldTranslate('UPC'));
check(' Package agora passa', v.shouldTranslate('Package'));
check(' Variant (optional) agora passa', v.shouldTranslate('Variant (optional)'));
check(' Regressão: JSON continua rejeitado', !v.shouldTranslate('JSON'));
check(' Regressão: dark:text-white continua CSS', !v.shouldTranslate('dark:text-white'));
check(' Regressão: PATH continua env var', !v.shouldTranslate('PATH'));

// --- Extração: chains + template literal + trailing ---
const parser = new VueParser();
const sfc = `<template>
  <div>{{ activeWindowMinutes }} minutes</div>
</template>
<script setup>
notice.value = 'Removed carton ' + displayCode(record.code) + '. Its next scan will ask what is inside.';
if (confirm(\`Remove "\${question.label}"?\`)) { go(); }
</script>`;
let ex;
try { ex = parser.parse(sfc); } catch (e) { console.log('parse error:', e.message); ex = { items: [] }; }
const texts = (ex.items || []).map((i) => i.text);
console.log('extraídos:', JSON.stringify(texts));
check('extração: chain notice com {placeholder}', texts.includes('Removed carton {placeholder}. Its next scan will ask what is inside.'));
check('extração: template literal com {p0}', texts.includes('Remove "{p0}"?'));
check('extração: trailing "minutes"', texts.includes('minutes'));

// --- Replace: chains, template, trailing, ||-literals ---
const r = new VueReplacer();
const keyMap = new Map([
  ['Commons|text|minutes', 'Commons.text.minutes'],
  ['Commons|text|Active', 'Commons.text.active'],
  ['Pages.People|text|Removed carton {placeholder}. Its next scan will ask what is inside.', 'Pages.text.removed_carton_notice'],
  ['Pages.People|text|Remove "{p0}"?', 'Pages.text.remove_this_item'],
  ['Pages.People|text|Could not save category.', 'Pages.text.could_not_save_category'],
]);
// trailing replace
const tT = r.replace(`<template><div>{{ activeWindowMinutes }} minutes</div></template>`, keyMap, 'Pages.X', {});
check('replace: trailing {{ n }} minutes curado', tT.content.includes(`{{ activeWindowMinutes }} {{ $t('Commons.text.minutes') }}`));
// JsxReplacer direto: chain + template + ||
const j = new JsxReplacer();
const script = `notice.value = 'Removed carton ' + displayCode(record.code) + '. Its next scan will ask what is inside.';
if (confirm(\`Remove "\${question.label}"?\`)) { go(); }
const fb = err || 'Could not save category.';`;
const jr = j.replace(script, keyMap, 'Pages.People', {});
console.log('script transformado:', JSON.stringify(jr.content));
check('chain: notice virou t() com placeholder', jr.content.includes(`t('Pages.text.removed_carton_notice', { placeholder: displayCode(record.code) })`));
check('template: confirm virou t() com p0', jr.content.includes(`t('Pages.text.remove_this_item', { p0: question.label })`));
check('||: fallback virou t()', jr.content.includes(`t('Pages.text.could_not_save_category')`));
check('||: fallback não ficou com $t(', !jr.content.includes(`$t('Pages.text.could_not_save_category')`));
// idempotência
const jr2 = j.replace(jr.content, keyMap, 'Pages.People', {});
check('script idempotente', jr2.changeCount === 0);

// --- Guards em produção: value:/to: intocados ---
const script2 = `const o = { value: 'other', to: 'approved' };
const cmp = x === 'none';
label: 'Active',`;
const jr3 = j.replace(script2, keyMap, 'Pages.X', {});
check('guard: value: \'other\' intocado', jr3.content.includes(`value: 'other'`));
check('guard: to: \'approved\' intocado', jr3.content.includes(`to: 'approved'`));
check('guard: === \'none\' intocado', jr3.content.includes(`x === 'none'`));
check('guard: label: \'Active\' virou t() (fora da lista técnica)', jr3.content.includes(`label: $t('Commons.text.active')`) || jr3.content.includes(`label: t('Commons.text.active')`));

const failed = fails;
console.log(failed ? `\n${failed} FAIL` : '\nTUDO OK');
process.exit(failed ? 1 : 0);
