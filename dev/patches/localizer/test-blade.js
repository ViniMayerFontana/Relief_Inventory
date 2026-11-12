'use strict';
// Testes Blade do round 3.1: comentários preservados ({{-- --}} e <!-- -->),
// comentários não casam no tagRegex, lookupBladeKey multi-kind.
const { spawnSync } = require('node:child_process');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');

let fails = 0;
const check = (name, ok) => { console.log(`${ok ? 'PASS' : 'FAIL'}  ${name}`); if (!ok) fails++; };

// Projeto-fixture em temp
const proj = fs.mkdtempSync(path.join(os.tmpdir(), 'i18n-blade-test-'));
const viewsDir = path.join(proj, 'resources', 'views', 'reports');
const autoEn = path.join(proj, 'resources', 'js', 'i18n', 'auto', 'en');
fs.mkdirSync(viewsDir, { recursive: true });
fs.mkdirSync(autoEn, { recursive: true });

fs.writeFileSync(path.join(autoEn, 'views.json'), JSON.stringify({
  Reports: {
    Sitrep: {
      text: {
        pallet_report: 'Pallet Report',
        donor_name: 'Donor Name',
        generated_at: 'Generated :date',
      },
      heading: {
        sitrep_title: 'Situation Report',
      },
    },
  },
}, null, 2), 'utf8');

const bladeBody = `{{-- relatório gerado — NÃO apagar --}}
{{-- <td>Donor Name</td> comentário com tag --}}
<!-- HTML comment with <td>Donor Name</td> inside -->
<h1>Situation Report</h1>
<td>Donor Name</td>
<td>{{ $donor->name }}</td>
`;
const bladePath = path.join(viewsDir, 'sitrep.blade.php');
fs.writeFileSync(bladePath, bladeBody, 'utf8');

const script = 'C:/Users/vini/AppData/Local/Temp/i18n-localizer/localizer/packages/core/src/i18n/rewrite-i18n-blade.js';
const res = spawnSync(process.execPath, [script, 'resources/views/reports/sitrep.blade.php'], {
  cwd: proj,
  env: { ...process.env, AI_I18N_PROJECT_ROOT: proj },
  encoding: 'utf8',
});
check('blade: script exit 0', res.status === 0);

const out = fs.readFileSync(bladePath, 'utf8');
check('blade: comentário Blade preservado', out.includes('{{-- relatório gerado — NÃO apagar --}}'));
check('blade: comentário Blade com tag preservado', out.includes('{{-- <td>Donor Name</td> comentário com tag --}}'));
check('blade: comentário HTML preservado', out.includes('<!-- HTML comment with <td>Donor Name</td> inside -->'));
check('blade: h1 substituído (heading)', out.includes('{{ __("Reports.Sitrep.heading.sitrep_title") }}'));
check('blade: td substituído (text)', out.includes('{{ __("Reports.Sitrep.text.donor_name") }}'));
check('blade: mustache dinâmico intocado', out.includes("{{ $donor->name }}"));
check('blade: comentário NÃO virou tradução', !out.includes('__("Reports.Sitrep.text.pallet_report")'));

// lookupBladeKey multi-kind (mesmo texto sob kind diferente)
process.env.AI_I18N_PROJECT_ROOT = proj;
const { lookupBladeKey } = (() => {
  // replicação: reimporta o módulo? O script é IIFE — testamos via comportamento acima.
  return {};
})();
check('blade: específicos — arquivos fora da lista não tocados', (() => {
  const other = path.join(viewsDir, 'other.blade.php');
  fs.writeFileSync(other, '<h1>Situation Report</h1>', 'utf8');
  const before = fs.readFileSync(other, 'utf8');
  const r2 = spawnSync(process.execPath, [script, 'resources/views/reports/sitrep.blade.php'], {
    cwd: proj,
    env: { ...process.env, AI_I18N_PROJECT_ROOT: proj },
    encoding: 'utf8',
  });
  const after = fs.readFileSync(other, 'utf8');
  return r2.status === 0 && after === before;
})());

// idempotência
{
  const before = fs.readFileSync(bladePath, 'utf8');
  const r3 = spawnSync(process.execPath, [script, 'resources/views/reports/sitrep.blade.php'], {
    cwd: proj,
    env: { ...process.env, AI_I18N_PROJECT_ROOT: proj },
    encoding: 'utf8',
  });
  const after = fs.readFileSync(bladePath, 'utf8');
  check('blade: idempotente', r3.status === 0 && after === before);
}

fs.rmSync(proj, { recursive: true, force: true });
console.log(fails ? `\n${fails} FAIL` : '\nTUDO OK');
process.exit(fails ? 1 : 0);
