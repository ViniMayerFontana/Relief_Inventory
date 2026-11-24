{{-- Training Mode setup packet (TrainingAdminController::setupPacketBuilder): what the last Prepare Training loaded, so
     trainers can stage the floor to match — the offers Station 1 matches the trainer's own goods to,
     where each scanned item goes for Stations 3–5 (a placement list, and a contents slip per spot / load to cut apart), and
     a plain sign per station. $summary =
     training_settings.prepared_summary; $stations = TrainingMode::STATIONS. --}}
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ __("reports.Training.SetupPacket.text.training_setup_packet") }}</title>
    <style>
        @page { size: {{ \App\Support\ReportPaper::size() }}; margin: 0.5in 0.55in; }
        @page sign { size: {{ \App\Support\ReportPaper::size() }} landscape; margin: 0.5in; }
        body { font-family: Arial, sans-serif; color: #222; margin: 0; font-size: 11px; line-height: 1.4; }
        h1 { font-size: 22px; margin: 0; }
        .subtitle { color: #666; margin: 2px 0 12px 0; }
        h2 { font-size: 14px; color: #1e3a8a; border-bottom: 2px solid #1e3a8a; padding-bottom: 2px; margin: 14px 0 6px 0; }
        h3 { font-size: 12px; margin: 8px 0 3px 0; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 6px; }
        th, td { border: 1px solid #bbb; padding: 3px 6px; text-align: left; vertical-align: top; }
        th { background: #eef2ff; }
        td.num, th.num { text-align: right; width: 50px; }
        .note { color: #555; }
        .warning { color: #9a3412; font-weight: bold; }
        .section { page-break-inside: avoid; }
        .new-page { page-break-before: always; }
        .slip { border: 2px dashed #888; padding: 10px 14px; margin-bottom: 14px; page-break-inside: avoid; }
        .slip-station { font-size: 12px; color: #555; text-transform: uppercase; letter-spacing: 1px; }
        .slip-title { font-size: 24px; font-weight: bold; margin: 2px 0 6px 0; }
        .slip table { font-size: 13px; }
        .sign { page: sign; page-break-before: always; text-align: center; padding-top: 1.4in; }
        .sign-number { font-size: 150px; font-weight: bold; line-height: 1; }
        .sign-name { font-size: 90px; margin-top: 30px; line-height: 1; }
    </style>
</head>
<body>
    @php
        $itemRows = function (array $items) {
            return collect($items)->map(fn ($i) => ['what' => $i['name'], 'acs' => trim($i['number'].' '.$i['type']), 'qty' => $i['qty']]);
        };
        $slips = [];
        $slips[] = ['station' => 3, 'title' => 'Sorting area table', 'sub' => 'Already sorted — build new pallets from these', 'items' => $summary['sorting_area']];
        foreach ($summary['warehouse_pallets'] as $p) {
            $slips[] = ['station' => 4, 'title' => 'Spot '.$p['location'].' — pallet '.$p['tag'], 'sub' => 'Put pallet label '.$p['tag'].' on this tray', 'items' => $p['items']];
        }
        foreach ($summary['orders_to_ship'] as $o) {
            $slips[] = ['station' => 5, 'title' => __('reports.Training.SetupPacket.text.ready_to_ship', ['p0' => $o['id']]), 'sub' => $o['partner'], 'items' => $o['items']];
        }
    @endphp

    <h1>{{ __("reports.Training.SetupPacket.text.training_setup_packet") }}</h1>
    <div class="subtitle">{{ config('app.name') }} — {{ __('reports.Training.SetupPacket.text.prepared_date', ['date' => CarbonCarbon::parse($summary['prepared_at'])->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y \à\s H:i' : 'F j, Y g:i A')]) }}
— {{ __('reports.Training.SetupPacket.text.scanned_summary', ['p0' => $summary['products']['units'], 'p1' => $summary['products']['distinct']]) }}

    @foreach ($summary['warnings'] ?? [] as $warning)
        <p class="warning">{{ $warning }}</p>
    @endforeach

    <div class="section">
        <h2>{{ __("reports.Training.SetupPacket.text.how_it_works") }}</h2>
        <p>{{ __('reports.Training.SetupPacket.text.how_it_works_paragraph') }}</p>
        <table>
            <thead><tr><th>{{ __("commons.text.station") }}</th><th>{{ __("commons.text.put_out") }}</th><th class="num">{{ __("commons.text.items") }}</th></tr></thead>
            <tbody>
                <tr><td>1 {{ $stations[1] }}</td><td>{{ __('reports.Training.SetupPacket.text.boxes_own_goods', ['p0' => count($summary['offers'])]) }}</td><td class="num">{{ __('reports.Training.SetupPacket.text.yours') }}</td></tr>
                <tr><td>2 {{ $stations[2] }}</td><td>{{ __("reports.Training.SetupPacket.text.nothing_the_teams_sort") }}</td><td class="num">0</td></tr>
                <tr><td>3 {{ $stations[3] }}</td><td>{{ __("reports.Training.SetupPacket.text.sorted_goods_on_the") }}</td><td class="num">{{ collect($summary['sorting_area'])->sum('qty') }}</td></tr>
                <tr><td>4 {{ $stations[4] }}</td><td>{{ __('reports.Training.SetupPacket.text.trays_and_orders', ['p0' => count($summary['warehouse_pallets']), 'p1' => count($summary['orders_to_fill'])]) }}</td><td class="num">{{ collect($summary['warehouse_pallets'])->flatMap(fn ($p) => $p['items'])->sum('qty') }}</td></tr>
                <tr><td>5 {{ $stations[5] }}</td><td>{{ __('reports.Training.SetupPacket.text.picked_at_door', ['p0' => count($summary['orders_to_ship'])]) }}</td><td class="num">{{ collect($summary['orders_to_ship'])->flatMap(fn ($o) => $o['items'])->sum('qty') }}</td></tr>
                <tr><td>6 {{ $stations[6] }}</td><td>{{ __("reports.Training.SetupPacket.text.nothing_each_team_delivers") }}</td><td class="num">0</td></tr>
            </tbody>
        </table>
        <p class="note">{{ __('reports.Training.SetupPacket.text.tape_note', ['p0' => implode(', ', $summary['locations'])]) }}</p>
    </div>

    <div class="section">
        <h2>{{ __('reports.Training.SetupPacket.text.station1_offers', ['p0' => $stations[1]]) }}</h2>
        <p class="note">{{ __("reports.Training.SetupPacket.text.put_out_boxes_of") }}</p>
        <table>
            <thead><tr><th>{{ __("commons.text.offer") }}</th><th>{{ __("commons.text.donor") }}</th><th>{{ __("commons.text.what_s_coming") }}</th></tr></thead>
            <tbody>
                @foreach ($summary['offers'] as $o)
                    <tr><td>{{ $o['id'] }}</td><td>{{ $o['donor'] }}</td><td>{{ $o['description'] }}</td></tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div class="section">
        <h2>{{ __('reports.Training.SetupPacket.text.station3_sorting', ['p0' => $stations[3]]) }}</h2>
        <p class="note">{{ __("reports.Training.SetupPacket.text.already_sorted_not_on") }}</p>
        <table>
            <tbody>@foreach ($itemRows($summary['sorting_area']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
        </table>
    </div>

    <div class="section">
        <h2>{{ __('reports.Training.SetupPacket.text.station4_trays', ['p0' => $stations[4]]) }}</h2>
        @foreach ($summary['warehouse_pallets'] as $p)
            <h3>Spot {{ $p['location'] }} — pallet {{ $p['tag'] }}</h3>
            <table>
                <tbody>@foreach ($itemRows($p['items']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
            </table>
        @endforeach
        <h3>{{ __('reports.Training.SetupPacket.text.orders_waiting') }}</h3>
        <table>
            <thead><tr><th>{{ __("commons.text.order") }}</th><th>{{ __('reports.Training.SetupPacket.text.partner') }}</th><th>{{ __("commons.text.lines") }}</th></tr></thead>
            <tbody>
                @foreach ($summary['orders_to_fill'] as $o)
                    <tr><td>{{ $o['id'] }}</td><td>{{ $o['partner'] }}</td>
                        <td>@foreach ($o['lines'] as $l){{ $l['qty'] }} × {{ $l['number'] }} {{ $l['name'] }}@if (! $loop->last), @endif @endforeach</td></tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div class="section">
        <h2>{{ __('reports.Training.SetupPacket.text.station5_door', ['p0' => $stations[5]]) }}</h2>
        @foreach ($summary['orders_to_ship'] as $o)
            <h3>Order #{{ $o['id'] }} — {{ $o['partner'] }}</h3>
            <table>
                <tbody>@foreach ($itemRows($o['items']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
            </table>
        @endforeach
    </div>

    <div class="section">
        <h2>{{ __('reports.Training.SetupPacket.text.station6_drivers', ['p0' => $stations[6]]) }}</h2>
        <p class="note">{{ __("reports.Training.SetupPacket.text.in_round_2_each") }}</p>
        <table>
            <thead><tr><th>{{ __("commons.text.team") }}</th><th>{{ __("commons.text.driver") }}</th><th>{{ __("commons.text.phone_2") }}</th><th>{{ __("commons.text.pin") }}</th></tr></thead>
            <tbody>
                @foreach ($summary['team_drivers'] as $d)
                    <tr><td>{{ $d['team'] }}</td><td>{{ $d['name'] }}</td><td>{{ $d['phone'] }}</td><td>{{ $d['pin'] }}</td></tr>
                @endforeach
            </tbody>
        </table>
        <p class="note">{{ __('reports.Training.SetupPacket.text.order_entry_partners', ['p0' => implode(', ', $summary['partners'])]) }}</p>
    </div>

    {{-- Contents slips: cut apart; one goes in each box / on each tray. --}}
    <div class="new-page">
        <h2>{{ __("reports.Training.SetupPacket.text.contents_slips_cut_apart") }}</h2>
        @foreach ($slips as $slip)
            <div class="slip">
                <div class="slip-station">Station {{ $slip['station'] }} — {{ $stations[$slip['station']] }}</div>
                <div class="slip-title">{{ $slip['title'] }}</div>
                <div class="note">{{ $slip['sub'] }}</div>
                <table>
                    <tbody>@foreach ($itemRows($slip['items']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
                </table>
            </div>
        @endforeach
    </div>

    @foreach ($stations as $number => $name)
        <div class="sign">
            <div class="sign-number">Station {{ $number }}</div>
            <div class="sign-name">{{ $name }}</div>
        </div>
    @endforeach
</body>
</html>
