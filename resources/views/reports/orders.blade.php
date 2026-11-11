<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ __("Reports.Orders.text.outstanding_orders_report") }}</title>
    <style>
        @page {
            size: {{ \App\Support\ReportPaper::size() }};
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Outstanding Orders Report — {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}";
                font-family: Arial, sans-serif;
                font-size: 9px;
                color: #888;
            }
            @top-right {
                content: "Page " counter(page) " of " counter(pages);
                font-family: Arial, sans-serif;
                font-size: 9px;
                color: #888;
            }
        }
        @page :first {
            margin-top: 0.5in;
            @top-left { content: none; }
            @top-right { content: none; }
        }
        body {
            font-family: Arial, sans-serif;
            color: #222;
            margin: 0;
            padding: 0;
        }
        h1 {
            font-size: 24px;
            margin: 0 0 2px 0;
        }
        .subtitle {
            color: #666;
            font-size: 13px;
            margin-bottom: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11.5px;
        }
        thead {
            display: table-header-group;
        }
        tr.order-row {
            break-inside: avoid;
            page-break-inside: avoid;
        }
        th, td {
            text-align: left;
            padding: 4px 8px;
            border-bottom: 1px solid #eee;
        }
        th {
            color: #666;
            font-weight: normal;
            border-bottom: 2px solid #ccc;
        }
        td.num, th.num {
            text-align: right;
        }
        .lines {
            font-size: 10.5px;
            color: #555;
            padding: 0 8px 8px 24px;
            border-bottom: 1px solid #eee;
        }
        .lines span {
            margin-right: 14px;
        }
        .status-badge {
            font-size: 9px;
            font-weight: bold;
            text-transform: uppercase;
            letter-spacing: 0.03em;
            color: #92400e;
            background: #fef3c7;
            padding: 1px 5px;
            border-radius: 6px;
        }
        .disclaimer {
            font-size: 11px;
            color: #888;
            font-style: italic;
            border-top: 1px solid #ddd;
            padding-top: 6px;
            margin-top: 26px;
        }
    </style>
</head>
<body>
    <h1>{{ __("Reports.Orders.text.outstanding_orders_report") }}</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; every order not yet shipped, {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}
    </div>

    <table>
        <thead>
            <tr>
                <th>{{ __("Commons.text.order") }}</th>
                <th>Partner</th>
                <th>{{ __("Commons.text.status_2") }}</th>
                <th>{{ __("Commons.text.order_date") }}</th>
                <th>{{ __("Commons.text.needed_by") }}</th>
                <th>{{ __("Commons.text.fulfillment") }}</th>
                <th class="num">{{ __("Commons.text.lines") }}</th>
                <th class="num">{{ __("Commons.text.qty_requested") }}</th>
            </tr>
        </thead>
        <tbody>
            @forelse($records as $order)
                <tr class="order-row">
                    <td>{{ $order['id'] }}</td>
                    <td>{{ $order['partner'] ?? '(no partner)' }}</td>
                    <td><span class="status-badge">{{ $order['status'] }}</span></td>
                    <td>{{ $order['order_date'] }}</td>
                    <td>{{ $order['needed_by_date'] ?: '—' }}</td>
                    <td>{{ $order['fulfillment_method'] }}</td>
                    <td class="num">{{ $order['line_count'] }}</td>
                    <td class="num">{{ $order['qty_requested'] }}</td>
                </tr>
                @if($order['lines']->isNotEmpty())
                    <tr>
                        <td colspan="8" class="lines">
                            @foreach($order['lines'] as $line)
                                <span>{{ $line['display_number'] ?? '(unnumbered)' }} {{ $line['itemtype'] }} &times; {{ $line['qty_requested'] }} {{ $line['unit'] }}</span>
                            @endforeach
                        </td>
                    </tr>
                @endif
            @empty
                <tr><td colspan="8">{{ __("Reports.Orders.text.no_outstanding_orders") }}</td></tr>
            @endforelse
        </tbody>
    </table>

    <div class="disclaimer">
        {{ __("Reports.Orders.text.includes_every_order_in") }}
    </div>
</body>
</html>
