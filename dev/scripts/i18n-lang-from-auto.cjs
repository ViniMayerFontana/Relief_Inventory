// Gera os arquivos lang/{en,pt_BR}/{commons,reports,errors}.php a partir dos
// JSONs de locale do vue-i18n (resources/js/i18n/auto/{locale}/*.json) mais um
// overlay manual (i18n-lang-extra.json, opcional).
//
// Por que existe: a CLI @ai-localizer injeta __() nos blades com chaves
// pontuadas cujo PRIMEIRO segmento é o nome do arquivo de lang exigido pelo
// tradutor do Laravel (ex.: __('Commons.text.donor_report') → lang/pt_BR/Commons.php).
// Os JSONs auto alimentam o vue-i18n (front), mas o Blade lê PHP — sem estes
// arquivos, os relatórios renderizam chave crua. As chaves dos blades foram
// normalizadas para o 1º segmento MINÚSCULO (commons./reports./errors.) para
// que os arquivos de lang não colidam com outros existentes em filesystems
// case-insensitive (Windows/macOS: Reports.php == reports.php).
//
// Gerado sob demanda, nunca à mão:
//
//   node dev/scripts/i18n-lang-from-auto.cjs
//
'use strict';
const fs = require('node:fs');
const path = require('node:path');

const root = path.resolve(__dirname, '..', '..');
const autoDir = (...p) => path.join(root, 'resources', 'js', 'i18n', 'auto', ...p);

// Namespace CamelCase (como a CLI grava nos JSONs/blades) → arquivo de lang
// minúsculo exigido pelas chaves normalizadas dos blades.
const TARGETS = [
  { ns: 'Commons', dest: 'commons.php' },
  { ns: 'Reports', dest: 'reports.php' },
  { ns: 'Errors', dest: 'errors.php' },
];
const LOCALES = ['en', 'pt_BR'];

// Chaves pré-existentes (task-4) que vivem no mesmo arquivo e não vêm dos JSONs:
// __('reports.generated_at'/'reports.printed') são usadas nos footers dos relatórios.
const MANUAL_BASE = {
  'reports.php': {
    en: { generated_at: 'generated :date', printed: 'printed :date' },
    pt_BR: { generated_at: 'gerado em :date', printed: 'impresso em :date' },
  },
};

// Overlay manual: chaves __() escritas à mão (não extraídas pela CLI), mescladas
// por último. Mesma forma dos JSONs auto: { Commons: {...}, Errors: {...} }.
const extraPath = path.join(__dirname, 'i18n-lang-extra.json');
const extra = fs.existsSync(extraPath)
  ? JSON.parse(fs.readFileSync(extraPath, 'utf8'))
  : {};

function deepMerge(target, source) {
  for (const [k, v] of Object.entries(source)) {
    if (v && typeof v === 'object' && !Array.isArray(v)) {
      target[k] = target[k] && typeof target[k] === 'object' ? target[k] : {};
      deepMerge(target[k], v);
    } else {
      target[k] = v;
    }
  }
  return target;
}

function phpValue(value, indent) {
  const pad = '    '.repeat(indent);
  const padClose = '    '.repeat(indent - 1);
  if (value === null) return 'null';
  if (typeof value === 'boolean') return value ? 'true' : 'false';
  if (typeof value === 'number') return String(value);
  if (typeof value === 'string') {
    return "'" + value.replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";
  }
  if (Array.isArray(value)) {
    if (value.length === 0) return '[]';
    const items = value.map((v) => pad + phpValue(v, indent + 1));
    return "[\n" + items.join(",\n") + ",\n" + padClose + ']';
  }
  const entries = Object.entries(value);
  if (entries.length === 0) return '[]';
  const items = entries.map(([k, v]) => {
    const safeKey = /^[\w-]+$/.test(k) ? `'${k}'` : "'" + k.replace(/\\/g, '\\\\').replace(/'/g, "\\'") + "'";
    return pad + `${safeKey} => ` + phpValue(v, indent + 1);
  });
  return "[\n" + items.join(",\n") + ",\n" + padClose + ']';
}

let wrote = 0;
for (const locale of LOCALES) {
  // Lê todos os grupos de locale deste lado (commons/views/components/pages) e
  // indexa pelo primeiro segmento de namespace de cada grupo.
  const trees = {};
  for (const group of ['commons', 'views', 'components', 'pages']) {
    const p = autoDir(locale, `${group}.json`);
    if (!fs.existsSync(p)) continue;
    const json = JSON.parse(fs.readFileSync(p, 'utf8'));
    for (const [ns, subtree] of Object.entries(json)) {
      trees[ns] = trees[ns] && typeof trees[ns] === 'object' ? deepMerge(trees[ns], subtree) : subtree;
    }
  }
  if (extra[locale]) deepMerge(trees, extra[locale]);

  for (const { ns, dest } of TARGETS) {
    const subtree = trees[ns];
    if (!subtree || typeof subtree !== 'object') {
      console.warn(`[i18n-lang] aviso: namespace '${ns}' não encontrado em ${locale}`);
      continue;
    }
    const merged = MANUAL_BASE[dest] && MANUAL_BASE[dest][locale]
      ? deepMerge({ ...MANUAL_BASE[dest][locale] }, subtree)
      : subtree;
    const out = `<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

// GENERATED file — ${locale} strings for Blade __() keys under the '${ns.toLowerCase()}.' namespace.
// Source of truth: resources/js/i18n/auto/${locale}/*.json (+ dev/scripts/i18n-lang-extra.json).
// Regenerate with: node dev/scripts/i18n-lang-from-auto.cjs — do not hand-edit.

return ${phpValue(merged, 1)};
`;
    const destPath = path.join(root, 'lang', locale, dest);
    fs.writeFileSync(destPath, out, 'utf8');
    wrote++;
    console.log(`[i18n-lang] ${path.relative(root, destPath)} (${Object.keys(subtree).length} grupos de 1º nível)`);
  }
}
console.log(`[i18n-lang] ${wrote} arquivo(s) gerado(s).`);
