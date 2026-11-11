{{-- Shared shell for every printable Help guide (HelpReportController::builder).
     Each guide's own view only supplies its title and content sections, so
     styling and the header/footer stay identical across guides. --}}
<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="UTF-8">
    <title>@yield('title')</title>
    <style>
        /* Margins live on @page (not body padding) so every page of the guide keeps them. */
        @page { size: {{ \App\Support\ReportPaper::size() }}; margin: 36px 42px; }
        body {
            font-family: Arial, sans-serif;
            color: #222;
            margin: 0;
            font-size: 13px;
            line-height: 1.5;
        }
        h1 {
            font-size: 22px;
            margin: 0 0 4px 0;
        }
        .subtitle {
            color: #666;
            font-size: 12px;
            margin-bottom: 18px;
        }
        .section {
            margin-top: 22px;
        }
        .section h2 {
            font-size: 14px;
            border-bottom: 2px solid #1e3a8a;
            padding-bottom: 4px;
            margin-bottom: 10px;
            color: #1e3a8a;
        }
        ol, ul {
            margin: 0;
            padding-left: 20px;
        }
        li {
            margin-bottom: 8px;
        }
        .section h3 {
            font-size: 13px;
            margin: 12px 0 6px 0;
        }
        /* Links in a guide point into the app; on paper they read as plain text. */
        a {
            color: inherit;
            text-decoration: none;
        }
        code {
            font-family: "DejaVu Sans Mono", monospace;
            font-size: 12px;
        }
        li > p {
            margin: 0 0 6px 0;
        }
        li ul {
            margin-top: 6px;
        }
        .intro {
            background: #f3f4f6;
            border-radius: 6px;
            padding: 10px 14px;
            font-style: italic;
        }
        .footer {
            font-size: 10px;
            color: #888;
            border-top: 1px solid #ddd;
            padding-top: 6px;
            margin-top: 24px;
        }
    </style>
</head>
<body>
    <h1>@yield('title')</h1>
    <div class="subtitle">{{ config('app.name') }} &mdash; {{ __('reports.printed', ['date' => now()->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y' : 'F j, Y')]) }}</div>

@yield('content')

    <div class="footer">
        {{ __('help.footer') }}
    </div>
</body>
</html>
