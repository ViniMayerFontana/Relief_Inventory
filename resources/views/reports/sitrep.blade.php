<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ __("commons.text.situation_report") }}</title>
    <style>
        /* Margins live on @page (not body padding) so every page of a long county list keeps them. */
        @page { size: {{ \App\Support\ReportPaper::size() }}; margin: 0.75in 0.6in; }  /* office printers can't print within ~0.5in of the top edge */
        body {
            font-family: Arial, sans-serif;
            color: #222;
            margin: 0;
        }
        h1 {
            font-size: 24px;
            margin: 0 0 2px 0;
        }
        .subtitle {
            color: #666;
            font-size: 13px;
            margin-bottom: 4px;
        }
        .disclaimer {
            font-size: 11px;
            color: #888;
            font-style: italic;
            border-top: 1px solid #ddd;
            padding-top: 6px;
            margin-top: 24px;
        }
        .section {
            margin-top: 26px;
        }
        .section h2 {
            font-size: 15px;
            border-bottom: 2px solid #1e3a8a;
            padding-bottom: 4px;
            margin-bottom: 12px;
            color: #1e3a8a;
        }
        .stat_grid {
            display: flex;
            gap: 18px;
        }
        .stat_block {
            flex: 1;
            border: 1px solid #ddd;
            border-radius: 6px;
            padding: 12px 14px;
        }
        .stat_block h3 {
            font-size: 13px;
            margin: 0 0 8px 0;
        }
        /* Flex items must be plain blocks: weasyprint mis-sizes tables used directly as flex items. */
        .stat_grid > .stat_col {
            flex: 1;
        }
        .stat_row {
            display: flex;
            justify-content: space-between;
            font-size: 12px;
            padding: 3px 0;
            border-bottom: 1px solid #f0f0f0;
        }
        .stat_row strong {
            font-size: 14px;
        }
        .trend {
            font-size: 11px;
            font-weight: bold;
            margin-top: 6px;
        }
        .trend_up { color: #15803d; }
        .trend_down { color: #b91c1c; }
        .trend_static { color: #666; }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 12px;
        }
        th, td {
            text-align: left;
            padding: 5px 8px;
            border-bottom: 1px solid #eee;
        }
        th {
            color: #666;
            font-weight: normal;
            border-bottom: 2px solid #ccc;
        }
        td.num {
            text-align: right;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <h1>{{ __("commons.text.situation_report") }}</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; {{ __('reports.generated_at', ['date' => $data['generated_at']->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i T' : 'F j, Y \a\t g:i A T')]) }}
    </div>

    <div class="section">
        <h2>{{ __("commons.text.movement_summary") }}</h2>
        <div class="stat_grid">
            <div class="stat_block">
                <h3>{{ __("commons.text.orders_fulfilled") }}</h3>
                <div class="stat_row"><span>{{ __("commons.text.today") }}</span><strong>{{ $data['orders_fulfilled']['today'] }}</strong></div>
                <div class="stat_row"><span>{{ __("reports.Sitrep.text.last_7_days") }}</span><strong>{{ $data['orders_fulfilled']['last_7_days'] }}</strong></div>
                <div class="stat_row"><span>{{ __("reports.Sitrep.text.last_30_days") }}</span><strong>{{ $data['orders_fulfilled']['last_30_days'] }}</strong></div>
                <div class="stat_row"><span>{{ __("commons.text.all_time") }}</span><strong>{{ $data['orders_fulfilled']['all_time'] }}</strong></div>
                <div class="trend trend_{{ $data['orders_trend']['direction'] }}">
                    Trend: {{ ucfirst($data['orders_trend']['direction']) }}
                    @if($data['orders_trend']['percent'] !== null) ({{ $data['orders_trend']['percent'] }}%) @endif
                    vs. prior 7 days
                </div>
            </div>
            <div class="stat_block">
                <h3>{{ __("commons.text.donations_completed") }}</h3>
                <div class="stat_row"><span>{{ __("commons.text.today") }}</span><strong>{{ $data['donations_completed']['today'] }}</strong></div>
                <div class="stat_row"><span>{{ __("reports.Sitrep.text.last_7_days") }}</span><strong>{{ $data['donations_completed']['last_7_days'] }}</strong></div>
                <div class="stat_row"><span>{{ __("reports.Sitrep.text.last_30_days") }}</span><strong>{{ $data['donations_completed']['last_30_days'] }}</strong></div>
                <div class="stat_row"><span>{{ __("commons.text.all_time") }}</span><strong>{{ $data['donations_completed']['all_time'] }}</strong></div>
                <div class="trend trend_{{ $data['donations_trend']['direction'] }}">
                    Trend: {{ ucfirst($data['donations_trend']['direction']) }}
                    @if($data['donations_trend']['percent'] !== null) ({{ $data['donations_trend']['percent'] }}%) @endif
                    vs. prior 7 days
                </div>
            </div>
        </div>
    </div>

    <div class="section">
        <h2>{{ __("commons.text.current_pipeline") }}</h2>
        <div class="stat_grid">
            <div class="stat_col"><table>
                <thead><tr><th>{{ __("commons.text.donations") }}</th><th class="num">{{ __("commons.text.count") }}</th></tr></thead>
                <tbody>
                    @foreach($data['pipeline']['donations'] as $stage => $count)
                        <tr><td>{{ $stage }}</td><td class="num">{{ $count }}</td></tr>
                    @endforeach
                </tbody>
            </table></div>
            <div class="stat_col"><table>
                <thead><tr><th>{{ __("commons.text.orders") }}</th><th class="num">{{ __("commons.text.count") }}</th></tr></thead>
                <tbody>
                    @foreach($data['pipeline']['orders'] as $stage => $count)
                        <tr><td>{{ $stage }}</td><td class="num">{{ $count }}</td></tr>
                    @endforeach
                </tbody>
            </table></div>
        </div>
    </div>

    @php
        $zipShown = count($data['zip_breakdown']['rows']);
        $zipTotal = $data['zip_breakdown']['zip_count'];
    @endphp
    {{-- County and zip side by side so the report stays on one page. --}}
    <div class="stat_grid">
        <div class="section stat_col">
            <h2>{{ __("reports.Sitrep.text.orders_by_county") }}</h2>
            @if(count($data['county_breakdown']))
                <table>
                    <thead><tr><th>{{ __("commons.text.county_2") }}</th><th class="num">{{ __("commons.text.orders") }}</th></tr></thead>
                    <tbody>
                        @foreach($data['county_breakdown'] as $row)
                            <tr><td>{{ $row['county'] }}</td><td class="num">{{ $row['count'] }}</td></tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <p>{{ __("reports.Sitrep.text.no_orders_placed_yet") }}</p>
            @endif
        </div>
        <div class="section stat_col">
            <h2>Orders by Zip @if($zipShown < $zipTotal)(top {{ $zipShown }} of {{ $zipTotal }})@endif</h2>
            @if($zipShown)
                <table>
                    <thead><tr><th>{{ __("commons.text.zip") }}</th><th class="num">{{ __("commons.text.orders") }}</th></tr></thead>
                    <tbody>
                        @foreach($data['zip_breakdown']['rows'] as $row)
                            <tr><td>{{ $row['zip'] }}</td><td class="num">{{ $row['count'] }}</td></tr>
                        @endforeach
                    </tbody>
                </table>
            @else
                <p>{{ __("reports.Sitrep.text.no_orders_placed_yet") }}</p>
            @endif
        </div>
    </div>

    <div class="section">
        <h2>{{ __("reports.Sitrep.text.stock_on_hand") }}</h2>
        <div class="stat_row"><span>{{ __("reports.Sitrep.text.item_types_stocked") }}</span><strong>{{ $data['inventory_summary']['item_types_with_stock'] }}</strong></div>
        <div class="stat_row"><span>{{ __("reports.Sitrep.text.total_units_on_hand") }}</span><strong>{{ $data['inventory_summary']['total_units_on_hand'] }}</strong></div>
        @if(count($data['inventory_summary']['top_categories']))
            <table style="margin-top: 8px;">
                <thead><tr><th>{{ __("commons.text.top_categories") }}</th><th class="num">{{ __("commons.text.units") }}</th></tr></thead>
                <tbody>
                    @foreach($data['inventory_summary']['top_categories'] as $cat)
                        <tr><td>{{ $cat['category'] }}</td><td class="num">{{ $cat['units'] }}</td></tr>
                    @endforeach
                </tbody>
            </table>
        @endif
    </div>

    <div class="disclaimer">
        {{ __("reports.Sitrep.text.this_is_a_live") }}
    </div>
</body>
</html>
