<!DOCTYPE html>
<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
<!--
    Custom maintenance-mode page, shown instead of Laravel's plain "503
    Service Unavailable" text whenever the app is in `artisan down`.
    Deliberately self-contained (no Vite/build assets, no app layout) since
    maintenance mode is exactly the moment those may be mid-rebuild —
    see scripts/update.sh, which wraps the deploy in `artisan down`/`up`.
-->
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="refresh" content="30">
    <title>{{ config('app.name', 'Relief Inventory') }} — {{ __("errors.Maintenance.text.maintenance") }}</title>
    <style>
        * { box-sizing: border-box; }
        html, body {
            height: 100%;
            margin: 0;
            font-family: ui-sans-serif, system-ui, -apple-system, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            background-color: #f9f9f9;
            color: #1f2933;
        }
        .wrap {
            min-height: 100%;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 2rem 1rem;
        }
        .card {
            max-width: 30rem;
            width: 100%;
            background: #ffffff;
            border-radius: 0.75rem;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1), 0 1px 2px rgba(0, 0, 0, 0.06);
            padding: 2.5rem 2rem;
            text-align: center;
        }
        .icon {
            width: 3.5rem;
            height: 3.5rem;
            margin: 0 auto 1.25rem;
            color: #007bff;
        }
        h1 {
            font-size: 1.375rem;
            margin: 0 0 0.75rem;
            color: #111827;
        }
        p {
            margin: 0 0 0.5rem;
            line-height: 1.6;
            color: #4b5563;
        }
        .note {
            margin-top: 1.5rem;
            font-size: 0.8125rem;
            color: #9ca3af;
        }
    </style>
</head>
<body>
    <div class="wrap" role="main">
        <div class="card">
            <svg class="icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                <circle cx="12" cy="12" r="9"></circle>
                <path d="M12 7v5l3 2"></path>
            </svg>
            <h1>{{ __("errors.Maintenance.text.back_shortly") }}</h1>
            <p>{{ __("errors.Maintenance.text.undergoing", ['app' => config('app.name', 'Relief Inventory')]) }}</p>
            <p>{{ __("errors.Maintenance.text.usually_minutes") }}</p>
            <p class="note">{{ __("errors.Maintenance.text.refreshes") }}</p>
        </div>
    </div>
</body>
</html>
