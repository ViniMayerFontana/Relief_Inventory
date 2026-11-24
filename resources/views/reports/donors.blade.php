@php
    $f = $report['filters'];
    $t = $report['totals'];
    $c = $report['thresholds'];
    $pct = fn ($v) => $v === null ? '—' : $v.'%';
    $range = match (true) {
        ! empty($f->from) && ! empty($f->to) => __('reports.Donors.text.donations_dated_from_to', ['from' => $f->from, 'to' => $f->to]),
        ! empty($f->from) => __('reports.Donors.text.donations_dated_from', ['from' => $f->from]),
        ! empty($f->to) => __('reports.Donors.text.donations_dated_to', ['to' => $f->to]),
        default => __('reports.Donors.text.all_donations'),
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
    <title>{{ __("commons.text.donor_report") }}</title>
    <style>
        @page {
            size: {{ \App\Support\ReportPaper::size() }};
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "{{ __('reports.Donors.text.header_with_date', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \\d\\e F \\d\\e Y \\à\\s H:i T' : 'F j, Y \\a\\t g:i A T')]) }}";
                font-family: Arial, sans-serif; font-size: 9px; color: #888;
            }
            @top-right {
                content: "{{ __('reports.Common.text.page') }} " counter(page) " {{ __('reports.Common.text.of') }} " counter(pages);
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
        tr.donor td { font-weight: bold; border-top: 1px solid #ccc; }
        tr.donation td { color: #555; font-size: 10px; }
        tr.donation td.indent { padding-left: 22px; }
        .muted { color: #888; font-weight: normal; }
        .disclaimer { font-size: 10.5px; color: #888; font-style: italic; border-top: 1px solid #ddd; padding-top: 6px; margin-top: 22px; }
    </style>
</head>
<body>
    <h1>{{ __("commons.text.donor_report") }}</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; {{ __('reports.Donors.text.subtitle', ['range' => $range]) }}, {{ __('reports.generated_at', ['date' => $generatedAt->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}
    </div>

    <div class="summary">
        {{ __('reports.Donors.text.donors_summary', ['p0' => $t['donors'], 'p1' => $t['donations'], 'p2' => number_format($t['units']), 'p3' => $pct($t['loss_percent'])]) }}
        {{ __('reports.Donors.text.watch_decline', ['p0' => $t['watch'], 'p1' => $t['decline'], 'p2' => $t['needs_review']]) }}
    </div>

    @if($report['donors']->isEmpty())
        <p>{{ $range === __('reports.Donors.text.all_donations') ? __('reports.Donors.text.no_donations') : __('reports.Donors.text.no_donations_range') }}</p>
    @else
        <h2>{{ __("commons.text.donors") }}</h2>
        <table>
            <thead>
                <tr>
                    <th>{{ __("reports.Donors.text.donor_donation") }}</th><th>{{ __("commons.text.standing") }}</th><th>{{ __("commons.text.suggested") }}</th><th class="num">{{ __("commons.text.donations") }}</th>
                    <th class="num">{{ __("commons.text.units") }}</th><th class="num">{{ __("commons.text.usable") }}</th><th class="num">{{ __("commons.text.outdated") }}</th>
                    <th class="num">{{ __("commons.text.trashed") }}</th><th class="num">{{ __("commons.text.diverted") }}</th><th class="num">{{ __("commons.text.loss") }}</th>
                </tr>
            </thead>
            <tbody>
                @foreach($report['donors'] as $d)
                    <tr class="donor">
                        <td>{{ $d['name'] }}</td>
                        <td>{{ $d['is_system'] ? '' : ucfirst($d['standing']) }}</td>
                        <td>{!! $d['is_system'] ? '' : ($d['suggested'] ? ucfirst($d['suggested']) : '<span class="muted">{{ __("reports.Donors.text.not_enough_data") }}</span>') !!}</td>
                        <td class="num">{{ $d['donations'] }}</td>
                        <td class="num">{{ number_format($d['units']) }}</td>
                        <td class="num">{{ number_format($d['usable']) }}</td>
                        <td class="num">{{ number_format($d['outdated']) }}</td>
                        <td class="num">{{ number_format($d['trashed']) }}</td>
                        <td class="num">{{ number_format($d['diverted']) }}</td>
                        <td class="num">{{ $pct($d['loss_percent']) }}</td>
                    </tr>
                    @foreach($d['donation_list'] as $n)
                        <tr class="donation">
                            <td class="indent">#{{ $n['id'] }} &middot; {{ $n['date'] }} &middot; {{ $statusLabels[$n['status']] ?? $n['status'] }}</td>
                            <td></td><td></td><td></td><td></td>
                            <td class="num">{{ number_format($n['usable']) }}</td>
                            <td class="num">{{ number_format($n['outdated']) }}</td>
                            <td class="num">{{ number_format($n['trashed']) }}</td>
                            <td class="num">{{ number_format($n['diverted']) }}</td>
                            <td class="num">{{ $pct($n['loss_percent']) }}</td>
                        </tr>
                    @endforeach
                @endforeach
            </tbody>
        </table>
    @endif

    <div class="disclaimer">
        {{ __('reports.Donors.text.disclaimer', ['min_donations' => $c['min_donations'], 'min_units' => $c['min_units'], 'watch_loss_percent' => $c['watch_loss_percent'], 'decline_loss_percent' => $c['decline_loss_percent'], 'decline_min_donations' => $c['decline_min_donations'], 'preferred_loss_percent' => $c['preferred_loss_percent'], 'preferred_min_donations' => $c['preferred_min_donations'], 'preferred_min_units' => $c['preferred_min_units']]) }}
    </div>
</body>
</html>
