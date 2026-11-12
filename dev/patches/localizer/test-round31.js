'use strict';
// Testes do round 3.1 (cura-pass): comentários no replace, arrays ALL_CAPS,
// chains com `new X()`, ensureTImport ancorado, texto nos dois lados do
// mustache, e falsos positivos de validador (password/.env/vírgula-prosa).
const { VueParser } = require('C:/Users/vini/AppData/Local/Temp/i18n-localizer/localizer/packages/core/src/i18n/lib/parsers/vueParser.js');
const { VueReplacer } = require('C:/Users/vini/AppData/Local/Temp/i18n-localizer/localizer/packages/core/src/i18n/lib/replacers/vueReplacer.js');
const { JsxReplacer } = require('C:/Users/vini/AppData/Local/Temp/i18n-localizer/localizer/packages/core/src/i18n/lib/replacers/jsxReplacer.js');
const { shouldTranslate } = require('C:/Users/vini/AppData/Local/Temp/i18n-localizer/localizer/packages/core/src/i18n/lib/validators/index.js');
const { isFilePath } = require('C:/Users/vini/AppData/Local/Temp/i18n-localizer/localizer/packages/core/src/i18n/lib/validators/technicalValidator.js');

let fails = 0;
const check = (name, ok) => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}`); if (!ok) fails++; };

// --- Validadores: falsos positivos corrigidos ---
check('validador: "Password" passa (era css_content)', shouldTranslate('Password') === true);
check('validador: "Both — public link, or staff filling it out for someone" passa', shouldTranslate('Both — public link, or staff filling it out for someone') === true);
check('validador: "Will use the one in the server .env" passa (era technical)', shouldTranslate('Will use the one in the server .env') === true);
check('validador: "Using the one in the server .env" passa', shouldTranslate('Using the one in the server .env') === true);
check('regressão: "config.json" continua caminho de arquivo', isFilePath('config.json') === true);
check('regressão: ".env" continua dotfile', isFilePath('.env') === true);
check('regressão: "JSON" continua rejeitado', shouldTranslate('JSON') === false);
check('regressão: "dark:text-white" continua CSS', shouldTranslate('dark:text-white') === false);
check('regressão: "Package" continua passando', shouldTranslate('Package') === true);
check('regressão: "UPC" continua passando', shouldTranslate('UPC') === true);

// --- Extração: ternário com os dois ramos ---
const parser = new VueParser();
const tern = parser.parse(`<script setup>
function methodLabel(method) {
\treturn method === 'pin' ? 'PIN unlock' : 'Password';
}
</script>`);
const ternTexts = (tern.items || []).map((i) => i.text);
check('extração: ternário pega "PIN unlock"', ternTexts.includes('PIN unlock'));
check('extração: ternário pega o alternate "Password"', ternTexts.includes('Password'));
check('extração: alvo de comparação "pin" NÃO vira chave', !ternTexts.includes('pin'));

// --- Extração: literal com aspa ESCAPADA fica inteiro (sem fragmento "s name.") ---
const escEx = parser.parse(`<script setup>
function f() {
\tthis.driverError = 'Enter the driver\\'s name.';
}
</script>`);
const escTexts = (escEx.items || []).map((i) => i.text);
check('extração: literal escapado inteiro com aspa simples', escTexts.includes("Enter the driver's name."));
check('extração: nenhum fragmento "s name."', !escTexts.some((t) => t === 's name.' || t === "'s name."));

// --- Replace: literal escapado vira t() com o texto decodificado ---
const escReplacer = new JsxReplacer();
const escKeyMap = new Map([['Pages|text|Enter the driver\'s name.', 'Pages.text.enter_the_drivers']]);
const escRep = escReplacer.replace(`this.driverError = 'Enter the driver\\'s name.';`, escKeyMap, 'Pages', {});
check('replace: literal escapado virou t()', escRep.content.includes("t('Pages.text.enter_the_drivers')"));

// --- Round 3.1c: array ALL_CAPS de UI-config (DISPOSITIONS) extrai labels/hints ---
const dispEx = parser.parse(`<script setup>
const DISPOSITIONS = [
{ key: 'new',      value: 'usable',   condition: 'new',  label: 'New',      hint: 'Unused, in original packaging - counted into inventory' },
{ key: 'usable',   value: 'usable',   condition: 'used', label: 'Usable',   hint: 'Used or opened, in good condition - counted into inventory' },
];
</script>`);
const dispTexts = (dispEx.items || []).map((i) => i.text);
check('3.1c caps-UI: label "New" extraída', dispTexts.includes('New'));
check('3.1c caps-UI: hint extraída', dispTexts.includes('Used or opened, in good condition - counted into inventory'));
check('3.1c caps-UI: value técnico NÃO extraída', !dispTexts.includes('usable'));
check('3.1c caps-UI: key técnica NÃO extraída', !dispTexts.includes('new'));

// --- Round 3.1c: emits/defineEmits intocados (extração e replace) ---
const emitEx = parser.parse(`<script setup>
const emit = defineEmits(['close']);
const x = 1;
</script>`);
check('3.1c emits: "close" de defineEmits NÃO extraída', !(emitEx.items || []).some((i) => i.text === 'close'));

const emitRep = new JsxReplacer().replace(`const emit = defineEmits(['close']);`, new Map([['Commons|text|close', 'Commons.text.close']]), 'Pages', {});
check('3.1c emits: defineEmits intocado no replace', emitRep.content.includes("defineEmits(['close'])"));

const emitsRep = new JsxReplacer().replace(`  emits: ['sent', 'downloaded'],`, new Map([['Commons|text|downloaded', 'Commons.text.downloaded']]), 'Pages', {});
check('3.1c emits: emits: [] intocado no replace', emitsRep.content.includes("emits: ['sent', 'downloaded']"));

// --- Round 3.1c: comparação no mustache do template intocada ---
const cmpRep = new VueReplacer().replace(`<template><span>{{ choice === 'download' ? 'Download' : 'Print' }}</span></template>`, new Map([['Commons|button|Download', 'Commons.button.download'], ['Commons|button|Print', 'Commons.button.print']]), 'Pages', {});
check('3.1c template: alvo de === intocado', cmpRep.content.includes("choice === 'download'"));
check('3.1c template: ramos de UI do ternário substituídos', cmpRep.content.includes("$t('Commons.button.download')") && cmpRep.content.includes("$t('Commons.button.print')"));

// --- Round 3.1c: font-family stack é CSS (não extrai, não substitui) ---
check('3.1c css: font stack rejeitado pelo validador', shouldTranslate("Figtree, 'RI Emoji', ui-sans-serif, system-ui, sans-serif") === false);
const fontRep = new JsxReplacer().replace(`Chart.defaults.font.family = "Figtree, 'RI Emoji', ui-sans-serif, system-ui, sans-serif";`, new Map([['Components|text|figtree', 'Components.text.figtree']]), 'Pages', {});
check('3.1c css: font stack intocado no replace', fontRep.content.includes("Chart.defaults.font.family = \"Figtree, 'RI Emoji', ui-sans-serif, system-ui, sans-serif\""));

// --- Round 3.1d: emit('name')/$emit('name') call sites intocados ---
const callEx = parser.parse(`<script setup>
function f() {
\temit('close');
\tthis.$emit("update:updates", option);
\tthis.$emit('saved', record);
}
</script>`);
const callTexts = (callEx.items || []).map((i) => i.text);
check('3.1d emit-calls: "close" NÃO extraída', !callTexts.includes('close'));
check('3.1d emit-calls: "update:updates" NÃO extraída', !callTexts.includes('update:updates'));
check('3.1d emit-calls: "saved" NÃO extraída', !callTexts.includes('saved'));

const callRep = new JsxReplacer().replace(`emit('close'); this.$emit("update:updates", option);`, new Map([['Commons|text|close', 'Commons.text.close'], ['Commons|text|update_updates', 'Commons.text.update_updates']]), 'Pages', {});
check('3.1d emit-calls: intocados no replace', callRep.content.includes("emit('close'); this.$emit(\"update:updates\", option);"));

// --- Round 3.1e: Tachyons por token EXATO ("email"/"password" não são CSS) ---
check('3.1e css: "Email" passa (era css_content via "ma")', shouldTranslate('Email') === true);
check('3.1e css: "Password" continua passando', shouldTranslate('Password') === true);
check('3.1e css: token Tachyons isolado "pa" continua CSS', shouldTranslate('pa') === false || !shouldTranslate('pa'));
check('3.1e css: "margin" continua CSS-like? (não é UI) — apenas não crasha', typeof shouldTranslate('margin') === 'boolean');

// --- Extração: comentários continuam fora (Issue 10) ---
const comEx = parser.parse(`<script setup>
// label: 'Active' em comentário
const x = 1;
</script>`);
check('extração: nada sai de comentário', (comEx.items || []).length === 0);

// --- Replace script: comentário intocado, literal real substituído ---
const jsx = new JsxReplacer();
// keyMap real: chave = "ns|kind|TEXTO" → valor = fullKey (como buildKeyMap faz)
const keyMap = new Map([
  ['Commons|label|Active', 'Commons.label.active'],
  ['Commons|text|none', 'Commons.text.none_2'],
  ['Commons|text|no override', 'Commons.text.no_override'],
  ['Commons|text|Any Day', 'Commons.text.any_day'],
  ['Commons|button|Verify Address', 'Commons.button.verify_address'],
  ['Pages|text|Saved.', 'Pages.text.saved'],
  ['Commons|text|Saved {placeholder}', 'Commons.text.saved_placeholder'],
  ['Commons|text|Administrator', 'Commons.text.administrator'],
  ['Pages|text|Sorting and Inventory', 'Pages.text.sorting_and_inventory'],
  ['Commons|text|Office', 'Commons.text.office'],
]);

const script1 = `const roleFilter = ref(''); // '' | 'none' | a role id
// The "no override" (below) falls back to this; same "Any Day" pattern.
// \`force\` bypasses the dedup key — used by the manual "Verify Address"
const label = 'Active';
`;
const r1 = jsx.replace(script1, keyMap, 'Pages', {});
check('replace: comentário 1 intocado', r1.content.includes("// '' | 'none' | a role id"));
check('replace: comentário 2 intocado ("no override")', r1.content.includes('"no override" (below) falls back'));
check('replace: comentário 2 intocado ("Any Day")', r1.content.includes('same "Any Day" pattern'));
check('replace: comentário 3 intocado ("Verify Address")', r1.content.includes('manual "Verify Address"'));
check('replace: label real substituído', r1.content.includes("const label = t('Commons.label.active')"));

// --- Replace script: array ALL_CAPS de roles intocado ---
const script2 = `const STAFF_ROLE_NAMES = ['Administrator', 'Sorting and Inventory', 'Office'];
const other = 'Saved.';
`;
const r2 = jsx.replace(script2, keyMap, 'Pages', {});
check('replace: STAFF_ROLE_NAMES intocado (roles = dados)', r2.content.includes("['Administrator', 'Sorting and Inventory', 'Office']"));
check('replace: literal fora do array substituído', r2.content.includes("const other = t('Pages.text.saved')"));

// --- Replace script: chain com new Date() vira JS válido ---
const script3 = `function f() { savedAt.value = 'Saved ' + new Date().toLocaleTimeString(); }
`;
const r3 = jsx.replace(script3, keyMap, 'Pages', {});
check('replace: chain com new Date() gera UMA chamada t() válida', r3.content.includes("t('Commons.text.saved_placeholder', { placeholder: new Date().toLocaleTimeString() })"));
check('replace: chain não deixou código quebrado', !r3.content.includes('placeholder: new })'));

// --- ensureTImport: comentário com "import" não engana a âncora ---
const script5 = `import axios from 'axios';
import { computed } from 'vue';

async function loadBatches() {
\ttry {
\t\tnotice.value = 'Saved.';
\t\t// from manage-import (upload/preview/commit) — a manage-import-only
\t\t// grant can still use the form above even if this list 403s.
\t} finally {
\t\tloadingBatches.value = false;
\t}
}
`;
const r5 = jsx.replace(script5, keyMap, 'Pages', {});
const importCount = (r5.content.match(/import \{ t \} from '@\/i18n'/g) || []).length;
check('replace: import injetado exatamente 1 vez', importCount === 1);
check('replace: import NÃO parou dentro da função (depois do último import real)', /import \{ t \} from '@\/i18n';\nimport \{ computed \}/.test(r5.content) || r5.content.indexOf("import { t } from '@/i18n';") < r5.content.indexOf('async function'));

// --- Replace template: texto nos DOIS lados do mustache ---
const vue = new VueReplacer();
const tKeyMap = new Map([
  ['Pages|heading|Active in the last', 'Pages.heading.active_in_the_last'],
  ['Commons|text|minutes', 'Commons.text.minutes'],
  ['Pages|text|and any carton barcodes pointing at it.', 'Pages.text.and_any_carton_barcodes'],
  ['Commons|text|Total', 'Commons.text.total'],
]);
const tpl1 = `<template><h2 class="x">
\tActive in the last {{ activeWindowMinutes }} minutes
\t<span class="y">({{ n }})</span>
</h2></template>`;
const t1 = vue.replace(tpl1, tKeyMap, 'Pages', {});
check('template: lead injetado (Active in the last)', t1.content.includes("{{ $t('Pages.heading.active_in_the_last') }}"));
check('template: trail injetado (minutes)', t1.content.includes("{{ $t('Commons.text.minutes') }}"));
check('template: expressão preservada', t1.content.includes('{{ activeWindowMinutes }}'));

const tpl2 = `<template><div>
\t\t\t\t\t{{ move.impact.pallet_assignments }} pallet stock entr{{ move.impact.pallet_assignments === 1 ? 'y' : 'ies' }}
\t\t\t\t\tand any carton barcodes pointing at it.
</div></template>`;
const t2 = vue.replace(tpl2, tKeyMap, 'Pages', {});
check('template: trail do nó multi-mustache injetado', t2.content.includes("{{ $t('Pages.text.and_any_carton_barcodes') }}"));
check('template: expressões do nó multi-mustache preservadas', (t2.content.match(/\{\{ move\.impact\.pallet_assignments/g) || []).length === 2);

// --- Replace template: comentário HTML intocado ---
const tpl3 = `<template><div>
\t<!-- TODO: usar o rótulo "Save" do design system aqui -->
\t<button>{{ n }}</button>
</div></template>`;
const t3 = vue.replace(tpl3, tKeyMap, 'Pages', {});
check('template: comentário HTML intocado', t3.content.includes('<!-- TODO: usar o rótulo "Save" do design system aqui -->'));

process.exit(fails === 0 ? 0 : 1);
