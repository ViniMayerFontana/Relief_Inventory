'use strict';
// Testes isolados do round 2 de patches (Issues 8-11 + attr/decode/leading-text).
const path = require('node:path');
const clone = path.join(process.env.TEMP, 'i18n-localizer', 'localizer');
const { VueReplacer } = require(path.join(clone, 'packages', 'core', 'src', 'i18n', 'lib', 'replacers', 'vueReplacer.js'));
const VueParserMod = require(path.join(clone, 'packages', 'core', 'src', 'i18n', 'lib', 'parsers', 'vueParser.js'));

const results = [];
function check(name, ok) { results.push([name, ok]); console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}`); }

const r = new VueReplacer();
const keyMap = new Map([
  ['Commons|text|Yes', 'Commons.text.yes'],
  ['Commons|text|No', 'Commons.text.no'],
  ['Pages.People|text|Confirm Delete — cannot be undone', 'Pages.button.confirm_delete_cannot_be'],
  ['Commons|text|Name', 'Commons.text.name'],
  ['Pages.People|text|Partner & Donor Info Guide', 'Pages.text.partner_donor_info_guide'],
  ['Commons|text|Active', 'Commons.text.active'],
  ['Commons|text|Archived', 'Commons.text.archived'],
  ['Commons|text|New User', 'Pages.button.new_user'],
  ['Commons|text|Add Location', 'Commons.text.add_location'],
]);

// --- Issue 8: ternário com TODOS os literais ---
const ternary = `<template><span>Volunteer: {{ record.is_volunteer ? 'Yes' : 'No' }}</span></template>`;
const t1 = r.replace(ternary, keyMap, 'Pages.People', {});
check('Issue 8: 1º literal do ternário substituído', t1.content.includes(`$t('Commons.text.yes')`));
check('Issue 8: else do ternário também substituído', t1.content.includes(`$t('Commons.text.no')`));

// Issue 8: primeiro com chave, segundo sem — só o primeiro muda
const ternary2 = `<template><span>{{ confirmingDelete ? 'Confirm Delete — cannot be undone' : 'Delete' }}</span></template>`;
const t2 = r.replace(ternary2, keyMap, 'Pages.People', {});
check('Issue 8: 1º com chave substituído', t2.content.includes(`$t('Pages.button.confirm_delete_cannot_be')`));
check('Issue 8: 2º sem chave fica intacto', t2.content.includes(`: 'Delete'`));

// Idempotência: rodar de novo sobre a saída não muda nada
const t2b = r.replace(t2.content, keyMap, 'Pages.People', {});
check('Issue 8: idempotência (re-run sem mudanças)', t2b.content === t2.content && t2b.changeCount === 0);

// --- Issue 11: segundo bloco <script> processado ---
const twoScripts = `<template><button>{{ $t('Commons.button.save') }}</button></template>
<script setup>
const x = 'First Block';
</script>
<script>
export default {
  methods: {
    fallback() { return 'New User'; }
  }
};
</script>`;
const t3 = r.replace(twoScripts, keyMap, 'Pages.Users', {});
check('Issue 11: literal no 2º bloco <script> substituído', t3.content.includes(`t('Pages.button.new_user')`));
check('Issue 11: 1º bloco intacto', t3.content.includes(`'First Block'`));

// --- decode &amp; (HelpLink) ---
const amp = `<template><HelpLink guide="people">Partner &amp; Donor Info Guide</HelpLink></template>`;
const t4 = r.replace(amp, keyMap, 'Pages.People', {});
check('decode: texto com &amp; substituído', t4.content.includes(`$t('Pages.text.partner_donor_info_guide'`));

// --- leading-text antes de mustache (thead) ---
const thead = `<template><th>Name{{ sortArrow('name') }}</th></template>`;
const t5 = r.replace(thead, keyMap, 'Pages.Users', {});
check('leading-text: "Name" traduzido antes da expressão', t5.content.includes(`{{ $t('Commons.text.name') }} {{ sortArrow('name') }}`));

// --- :options com literais dentro do array ---
const options = `<template><ComboBox :options="[{ id: 'active', name: 'Active' }, { id: 'archived', name: 'Archived' }]" /></template>`;
const t6 = r.replace(options, keyMap, 'Pages.LocationEntry', {});
check(':options: Active traduzido', t6.content.includes(`name: $t('Commons.text.active')`) || t6.content.includes(`name: $t('Commons.text.active')`));
check(':options: Archived traduzido', t6.content.includes(`$t('Commons.text.archived')`));
check(':options: ids intactos', t6.content.includes(`id: 'active'`) && t6.content.includes(`id: 'archived'`));
check(':options: expressão do array preservada', t6.content.includes(`:options="[{`));

// --- newrecordcaption ---
const nrc = `<template><RIForm title="T" newrecordcaption="Add Location" /></template>`;
const t7 = r.replace(nrc, keyMap, 'Pages.LocationEntry', {});
check('newrecordcaption: atributo virou bound $t', t7.content.includes(`:newrecordcaption="$t('Commons.text.add_location')"`));

// --- EXTRAÇÃO (vueParser) ---
const VueParser = VueParserMod.VueParser || VueParserMod.default || VueParserMod;
const parser = new VueParser();
const sfc = `<template>
  <div>Route:</div>
  <th>Name{{ sortArrow('name') }}</th>
  <span>{{ record.is_volunteer ? 'Yes' : 'No' }}</span>
</template>
<script setup>
// comentário com "Any Day" dentro
const STAFF_ROLE_NAMES = ['Administrator', 'Sorting and Inventory', 'Office'];
const opts = { value: 'other', label: 'Weight' };
const url = 'https://example.org/path';
</script>
<script>
export default {
  methods: { msg() { return 'Second block message'; } }
};
</script>`;
let ex;
try {
  ex = parser.parse(sfc);
} catch (e) {
  console.log('parse() error:', e.message);
  ex = { items: [] };
}
const texts = (ex.items || []).map((i) => i.text);
console.log('extraídos:', JSON.stringify(texts));
check('extração: "Route:" (1 palavra + dois-pontos) extraída', texts.includes('Route:'));
check('extração: leading-text "Name" extraída', texts.includes('Name'));
check('extração: ternário — Yes e No ambos extraídos', texts.includes('Yes') && texts.includes('No'));
check('Issue 10: comentário "Any Day" NÃO extraído', !texts.includes('Any Day'));
check('Issue 9: STAFF_ROLE_NAMES NÃO extraídos', !texts.includes('Administrator') && !texts.includes('Sorting and Inventory'));
check('Issue 9: value: \'other\' NÃO extraído', !texts.includes('other'));
check('Issue 9: label: \'Weight\' extraído', texts.includes('Weight'));
check('Issue 10: sem truncamento de URL (nenhum "https:" cru)', !texts.includes('https:'));
check('Issue 11 (extração): 2º bloco extraído', texts.includes('Second block message'));

const failed = results.filter(([, ok]) => !ok).length;
console.log(`\n${results.length - failed}/${results.length} PASS`);
process.exit(failed ? 1 : 0);
