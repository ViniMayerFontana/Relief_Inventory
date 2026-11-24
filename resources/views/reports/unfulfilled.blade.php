@php
    $range = match (true) {
        ! empty($filters['from']) && ! empty($filters['to']) => __('reports.Unfulfilled.text.orders_dated_from_to', ['from' => $filters['from'], 'to' => $filters['to']]),
        ! empty($filters['from']) => __('reports.Unfulfilled.text.orders_dated_from', ['from' => $filters['from']]),
        ! empty($filters['to']) => __('reports.Unfulfilled.text.orders_dated_to', ['to' => $filters['to']]),
        default => __('reports.Unfulfilled.text.all_orders'),
    };
    $totals = $report['totals'];
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ __("reports.Unfulfilled.text.unfulfilled_requests_report") }}</title>
    <style>
        @page {
            size: {{ \App\Support\ReportPaper::size() }};
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Unfulfilled Requests Report — {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}";
                font-family: Arial, sans-serif;
                font-size: 9px;
                color: #888;
            }
            @top-right {
                content: "{{ __('reports.Common.text.page') }} " counter(page) " {{ __('reports.Common.text.of') }} " counter(pages);
                font-family: Arial, sans-serif;
                font-size: 9px;
                color: #888;
            }
        }
        @page :first {
            margin-top: 0.75in;
            @top-left { content: none; }
            @top-right { content: none; }
        }
        body {
            font-family: Arial, sans-serif;
            color: #222;
            margin: 0;
        }
        h1 {
            font-size: 24px;
            margin: 0 0 2px 0;
        }
        h2 {
            font-size: 14px;
            border-bottom: 2px solid #1e3a8a;
            padding-bottom: 4px;
            margin: 22px 0 8px 0;
            color: #1e3a8a;
        }
        .subtitle {
            color: #666;
            font-size: 13px;
            margin-bottom: 14px;
        }
        .summary {
            font-size: 12px;
        }
        .summary strong {
            font-size: 14px;
        }
        /* Flex items must be plain blocks: weasyprint mis-sizes tables used directly as flex items. */
        .columns {
            display: flex;
            gap: 18px;
        }
        .columns > div {
            flex: 1;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
        }
        thead {
            display: table-header-group;
        }
        tr {
            break-inside: avoid;
        }
        th, td {
            text-align: left;
            padding: 3px 6px;
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
        tr.item td {
            font-weight: bold;
            border-top: 1px solid #ccc;
        }
        tr.loc td {
            color: #555;
            font-size: 10px;
        }
        tr.loc td.place {
            padding-left: 22px;
        }
        .short {
            color: #b91c1c;
        }
        .disclaimer {
            font-size: 10.5px;
            color: #888;
            font-style: italic;
            border-top: 1px solid #ddd;
            padding-top: 6px;
            margin-top: 22px;
        }
    </style>
</head>
<body>
    <h1>{{ __("reports.Unfulfilled.text.unfulfilled_requests_report") }}</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; {{ __('reports.Unfulfilled.text.subtitle', ['range' => $range]) }}, {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}
    </div>

    <div class="summary">
        {{ __('reports.Unfulfilled.text.summary', ['p0' => $totals['item_types'], 'p1' => $totals['requests'], 'p2' => number_format($totals['requested']), 'p3' => number_format($totals['filled']), 'p4' => number_format($totals['not_filled']), 'p5' => number_format($totals['cut_at_allocation']), 'p6' => number_format($totals['short_at_picking'])]) }}
    </div>

    @if($report['items']->isEmpty())
        <p>{{ $range === __('reports.Unfulfilled.text.all_orders') ? __('reports.Unfulfilled.text.none') : __('reports.Unfulfilled.text.none_range') }}</p>
    @else
        <div class="columns">
            @foreach(['county' => __('reports.Unfulfilled.text.county'), 'zip' => __('reports.Unfulfilled.text.zip')] as $field => $label)
                <div>
                    <h2>{{ __('reports.Unfulfilled.text.not_filled_by') }} {{ $label }}</h2>
                    <table>
                        <thead><tr>
                            <th>{{ $label }}</th><th class="num">{{ __("commons.text.requests") }}</th><th class="num">{{ __("commons.text.item_types") }}</th><th class="num">{{ __("commons.text.not_filled") }}</th>
                        </tr></thead>
                        <tbody>
                            @foreach($report['by_'.$field] as $row)
                                <tr>
                                    <td>{{ $row[$field] }}</td>
                                    <td class="num">{{ $row['requests'] }}</td>
                                    <td class="num">{{ $row['item_types'] }}</td>
                                    <td class="num">{{ number_format($row['not_filled']) }}</td>
                                </tr>
                            @endforeach
                        </tbody>
                    </table>
                </div>
            @endforeach
        </div>

        <h2>{{ __("reports.Unfulfilled.text.items_not_filled") }}</h2>
        <table>
            <thead>
                <tr>
                    <th>{{ __("commons.text.item") }}</th>
                    <th>{{ __('reports.Unfulfilled.text.item_county_zip') }}</th>
                    <th>{{ __("commons.text.unit") }}</th>
                    <th class="num">{{ __("commons.text.requests") }}</th>
                    <th class="num">{{ __("commons.text.requested") }}</th>
                    <th class="num">{{ __("commons.text.filled") }}</th>
                    <th class="num">{{ __("commons.text.not_filled") }}</th>
                    <th class="num">{{ __("reports.Unfulfilled.text.cut_at_allocation") }}</th>
                    <th class="num">{{ __("reports.Unfulfilled.text.short_at_picking") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach($report['items'] as $item)
                    <tr class="item">
                        <td>{{ $item['display_number'] ?? '—' }}</td>
                        <td>{{ $item['name'] }}</td>
                        <td>{{ $item['unit'] }}</td>
                        <td class="num">{{ $item['requests'] }}</td>
                        <td class="num">{{ number_format($item['requested']) }}</td>
                        <td class="num">{{ number_format($item['filled']) }}</td>
                        <td class="num short">{{ number_format($item['not_filled']) }}</td>
                        <td class="num">{{ number_format($item['cut_at_allocation']) }}</td>
                        <td class="num">{{ number_format($item['short_at_picking']) }}</td>
                    </tr>
                    @foreach($item['locations'] as $loc)
                        <tr class="loc">
                            <td></td>
                            <td class="place">{{ $loc['county'] }} &middot; {{ $loc['zip'] }}</td>
                            <td></td>
                            <td class="num">{{ $loc['requests'] }}</td>
                            <td class="num">{{ number_format($loc['requested']) }}</td>
                            <td class="num">{{ number_format($loc['filled']) }}</td>
                            <td class="num">{{ number_format($loc['not_filled']) }}</td>
                            <td class="num">{{ number_format($loc['cut_at_allocation']) }}</td>
                            <td class="num">{{ number_format($loc['short_at_picking']) }}</td>
                        </tr>
                    @endforeach
                @endforeach
            </tbody>
        </table>
    @endif

    <div class="disclaimer">
        {{ __('reports.Unfulfilled.text.disclaimer') }}
    </div>
</body>
</html>
