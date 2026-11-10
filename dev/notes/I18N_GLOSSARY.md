<!-- Cópia canônica e versionada deste glossário. Working copy (gitignored): .i18n-queue/GLOSSARY.md -->

# Glossário i18n — Relief Inventory (EN → pt-BR)

Fonte de verdade das escolhas de tradução. Mesmo termo = mesma tradução, em todas as telas.
Tom: profissional, logístico, adequado a operações de defesa civil e governo.

## Termos definidos

| EN | pt-BR | Notas |
|---|---|---|
| pallet | pallet | termo do domínio logístico; mantido em inglês |
| Pallet Report | Relatório de pallet | título do relatório PDF |
| Item Category Entry | Cadastro de categorias de itens | título da página (`<Head>`) |
| Item Category Management | Gerenciamento de categorias de itens | título do formulário (prop `title` do RIForm) |
| Category Name | Nome da categoria | label de campo; minúsculas em pt-BR |
| Search by Category Name... | Buscar por nome da categoria... | placeholder de busca |
| Turn it off | Desative-o | destaque (`<strong>`) na página de erro do Turnstile |
| Or give it keys | Ou forneça as chaves | destaque (`<strong>`) |
| set X to Y | defina X como Y | padrão para instruções de configuração |
| Cloudflare Turnstile | Cloudflare Turnstile | nome de produto; mantido |
| This page isn't set up yet | Esta página ainda não está configurada | `<h1>` da página de erro |
| dashboard | painel/dashboard | "dashboard do Cloudflare" quando referente ao produto |

## Limitações conhecidas da CLI `@ai-localizer/cli` v0.1.1 (achadas no piloto 2026-11-09)

1. **Falso positivo**: o comando `docker compose up -d` virou chave
   (`views.Errors.TurnstileMisconfigured.text.docker_compose_up_d`) — o backend Blade
   não roda validators de código. Tratamento: valor **VERBATIM em inglês** no
   `answers.json` (a saída renderizada fica idêntica ao original; nunca traduzir
   comandos/config).
2. **Wrap parcial**: os fragments `— set` (`commons.Commons.text.set`),
   `; then run:` e `, and set both` (views) são restos de parágrafos que contêm
   `<code>` inline; o backend Blade não injeta esses fragments (o parágrafo tem
   tags dentro). Estão traduzidos na base para consistência, mas não aparecem
   na tela.
3. `VueReplacer` para no primeiro `</template>` interno (regex não-gananciosa) —
   páginas com slots (todas as que usam RIForm) têm cobertura mínima.
4. Backend Blade sem alias de namespace `Commons` — textos de até 2 palavras
   nunca são substituídos em Blade.
5. Inconsistência de kind: o extract registra `<h1>` como `text`, o replacer
   procura `heading` — `<h1>` não é substituído.
6. Textos Vue com mustache `{{ }}` não são extraídos.
7. Chaves da fila vêm prefixadas pelo stem do arquivo de locale
   (`pages.Pages.title...`); o `answers.json` deve espelhar as chaves do
   `pending.json` verbatim.

## Notas de ambiente (para sessões futuras)

- A CLI está instalada **globalmente** (`npm.cmd i -g @ai-localizer/cli`); os scripts de
  fase do core ficam em
  `C:\Users\Vini\AppData\Roaming\npm\node_modules\@ai-localizer\cli\node_modules\@ai-localizer\core\src\i18n\`.
- Nesta máquina, `vite build` falha por interferência de antivírus/Defender com o binário
  esbuild ("Access is denied" na exclusão do temp, mesmo sem confinamento) — quirk
  ambiental, não relacionado ao i18n.
- As 5 limitações reportáveis têm issues redigidas em `Agents/UPSTREAM_ISSUES.md`
  (títulos e corpos em inglês, prontos para colar no GitHub).
