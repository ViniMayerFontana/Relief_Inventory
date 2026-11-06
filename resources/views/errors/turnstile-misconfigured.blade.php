<!DOCTYPE html>
<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
<!--
    Shown instead of a bare 500 when Cloudflare Turnstile is switched on but
    its keys are missing (see TurnstileService::misconfiguredResponse()).
    Self-contained, like 503.blade.php. The visitor may be a stranger, so it
    only names the setting names, never any values.
-->
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{{ config('app.name', 'Relief Inventory') }} — Configuração necessária</title>
    <style>
        * { box-sizing: border-box; }
        body { margin: 0; font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background: #f9f9f9; color: #1f2933; }
        .wrap { max-width: 40rem; margin: 3rem auto; padding: 0 1rem; }
        .card { background: #fff; border: 1px solid #d9dee3; border-radius: 8px; padding: 1.5rem; }
        h1 { margin-top: 0; font-size: 1.3rem; }
        code { background: #eef1f4; padding: 0.1rem 0.3rem; border-radius: 3px; font-size: 0.9em; }
        pre { background: #eef1f4; padding: 0.75rem; border-radius: 4px; overflow-x: auto; }
    </style>
</head>
<body>
<div class="wrap"><div class="card">
    <h1>Esta página ainda não foi configurada</h1>
    <p>Esta página usa o Cloudflare Turnstile (verificação contra bots), que está ativado, mas não tem chaves configuradas. O administrador do servidor precisa escolher uma das opções abaixo e, em seguida, reiniciar o aplicativo:</p>
    <p><strong>Desativá-lo</strong> (adequado para um site privado ou sem conexão) — defina <code>CLOUDFLARE_TURNSTILE_ENABLED</code> como <code>false</code>.</p>
    <p><strong>Ou configurar as chaves</strong> — defina <code>CLOUDFLARE_TURNSTILE_ENABLED</code> como <code>true</code> e configure <code>CLOUDFLARE_TURNSTILE_SITE_KEY</code> e <code>CLOUDFLARE_TURNSTILE_SECRET_KEY</code> (gratuitas no painel do Cloudflare; o servidor precisa de acesso à Internet).</p>
    <p>No Docker, essas opções ficam no bloco de configurações no início de <code>compose.yaml</code>; depois, execute:</p>
    <pre>docker compose up -d</pre>
</div></div>
</body>
</html>
