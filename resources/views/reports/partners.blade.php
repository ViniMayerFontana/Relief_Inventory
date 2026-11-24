@php
    $f = $report['filters'];
    $t = $report['totals'];
    $rate = fn ($v) => $v === null ? '—' : $v.'%';
    $range = match (true) {
        ! empty($f->from) && ! empty($f->to) => __('reports.Partners.text.orders_dated_from_to', ['from' => $f->from, 'to' => $f->to]),
        ! empty($f->from) => __('reports.Partners.text.orders_dated_from', ['from' => $f->from]),
        ! empty($f->to) => __('reports.Partners.text.orders_dated_to', ['to' => $f->to]),
        default => __('reports.Partners.text.all_orders'),
    };
@endphp
@php
    $statusLabels = [
        'Shopping Cart' => __('reports.Common.status.shopping_cart'),
        'New Order' => __('reports.Common.status.new_order'),
        'Filling' => __('reports.Common.status.filling'),
        'Ready to Fill' => __('reports.Common.status.ready_to_fill'),
        'Filled' => __('reports.Common.status.filled'),
        'Ready to Ship' => __('reports.Common.status.ready_to_ship'),
        'Shipped' => __('reports.Common.status.shipped'),
        'Delivered' => __('reports.Common.status.delivered'),
        'Delivered — Waiting on BOL' => __('reports.Common.status.awaiting_bol'),
        'Completed' => __('reports.Common.status.completed'),
        'Closed - Unfulfilled' => __('reports.Common.status.closed_unfulfilled'),
    ];
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ __("commons.text.partner_report") }}</title>
    <style>
        @page {
            size: {{ \App\Support\ReportPaper::size() }};
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "{{ __('reports.Partners.text.header_name') }} — {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}";
                font-family: Arial, sans-serif; font-size: 9px; color: #888;
            }
            @top-right {
                content: "Page " counter(page) " of " counter(pages);
                font-family: Arial, sans-serif; font-size: 9px; color: #888;
            }
        }
        @page :first {
            margin-top: 0.75in;
            @top-left { content: none; }
            @top-right { content: none; }
        }
        body { font-family: Arial, sans-serif; color: #222; margin: 0; }
        h1 { font-size: 24px; margin: 0 0 2px 0; }
        h2 { font-size: 14px; border-bottom: 2px solid #1e3a8a; padding-bottom: 4px; margin: 22px 0 8px 0; color: #1e3a8a; }
        .subtitle { color: #666; font-size: 13px; margin-bottom: 14px; }
        .summary { font-size: 12px; }
        .summary strong { font-size: 14px; }
        table { width: 100%; border-collapse: collapse; font-size: 11px; }
        thead { display: table-header-group; }
        tr { break-inside: avoid; }
        th, td { text-align: left; padding: 3px 6px; border-bottom: 1px solid #eee; }
        th { color: #666; font-weight: normal; border-bottom: 2px solid #ccc; }
        td.num, th.num { text-align: right; }
        tr.partner td { font-weight: bold; border-top: 1px solid #ccc; }
        tr.order td { color: #555; font-size: 10px; }
        tr.order td.indent { padding-left: 22px; }
        .disclaimer { font-size: 10.5px; color: #888; font-style: italic; border-top: 1px solid #ddd; padding-top: 6px; margin-top: 22px; }
    </style>
</head>
<body>
    <h1>{{ __("commons.text.partner_report") }}</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; {{ __('reports.Partners.text.subtitle', ['range' => $range]) }}, {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}
    </div>

    <div class="summary">
        {{ __('reports.Partners.text.partners_summary', ['p0' => $t['partners'], 'p1' => $t['requests'], 'p2' => number_format($t['requested']), 'p3' => number_format($t['filled']), 'p4' => $rate($t['fill_rate']), 'p5' => $t['shipped'], 'p6' => $t['delivered']]) }}
    </div>

    @if($report['partners']->isEmpty())
        <p>{{ __('reports.Partners.text.no_requests') }}{{ $range === __('reports.Partners.text.all_orders') && empty($f->county_id) ? '' : __('reports.Partners.text.no_requests_filters') }}.</p>
    @else
        <h2>{{ __("commons.text.by_county") }}</h2>
        <table>
            <thead><tr><th>{{ __("commons.text.county_2") }}</th><th class="num">{{ __('reports.Partners.text.partners_count') }}</th><th class="num">{{ __("commons.text.requests") }}</th><th class="num">{{ __("commons.text.requested") }}</th><th class="num">{{ __("commons.text.filled") }}</th></tr></thead>
            <tbody>
                @foreach($report['by_county'] as $row)
                    <tr>
                        <td>{{ $row['county'] }}</td>
                        <td class="num">{{ $row['partners'] }}</td>
                        <td class="num">{{ $row['requests'] }}</td>
                        <td class="num">{{ number_format($row['requested']) }}</td>
                        <td class="num">{{ number_format($row['filled']) }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        <h2>{{ __('reports.Partners.text.partners_count') }}</h2>
        <table>
            <thead>
                <tr>
                    <th>{{ __("reports.Partners.text.partner_request") }}</th><th>{{ __('reports.Partners.text.county_zip') }}</th><th class="num">{{ __("commons.text.requests") }}</th>
                    <th class="num">{{ __("commons.text.requested") }}</th><th class="num">{{ __("commons.text.filled") }}</th><th class="num">{{ __("commons.text.fill_rate") }}</th>
                    <th class="num">{{ __("commons.text.shipped") }}</th><th class="num">{{ __('reports.Partners.text.delivered') }}</th><th>{{ __("commons.text.last_request") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach($report['partners'] as $p)
                    <tr class="partner">
                        <td>{{ $p['name'] }}</td>
                        <td>{{ $p['county'] }} &middot; {{ $p['zip'] }}</td>
                        <td class="num">{{ $p['requests'] }}</td>
                        <td class="num">{{ number_format($p['requested']) }}</td>
                        <td class="num">{{ number_format($p['filled']) }}</td>
                        <td class="num">{{ $rate($p['fill_rate']) }}</td>
                        <td class="num">{{ $p['shipped'] }}</td>
                        <td class="num">{{ $p['delivered'] }}</td>
                        <td>{{ $p['last_request'] }}</td>
                    </tr>
                    @foreach($p['orders'] as $o)
                        <tr class="order">
                            <td class="indent">#{{ $o['id'] }} &middot; {{ $statusLabels[$o['status']] ?? $o['status'] }}</td>
                            <td>{{ $o['order_date'] }}</td>
                            <td></td>
                            <td class="num">{{ number_format($o['requested']) }}</td>
                            <td class="num">{{ number_format($o['filled']) }}</td>
                            <td></td><td></td><td></td><td></td>
                        </tr>
                    @endforeach
                @endforeach
            </tbody>
        </table>
    @endif

    <div class="disclaimer">
        {{ __('reports.Partners.text.disclaimer') }}
    </div>
</body>
</html>
