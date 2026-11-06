{{-- Training Mode setup packet (TrainingAdminController::setupPacketBuilder): what the last Prepare Training loaded, so
     trainers can stage the floor to match — the offers Station 1 matches the trainer's own goods to,
     where each scanned item goes for Stations 3–5 (a placement list, and a contents slip per spot / load to cut apart), and
     a plain sign per station. $summary =
     training_settings.prepared_summary; $stations = TrainingMode::STATIONS. --}}
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Pacote de Preparação do Treinamento</title>
    <style>
        @page { size: letter; margin: 0.5in 0.55in; }
        @page sign { size: letter landscape; margin: 0.5in; }
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
        $slips[] = ['station' => 3, 'title' => 'Mesa da área de triagem', 'sub' => 'Itens já triados — monte novos paletes com eles', 'items' => $summary['sorting_area']];
        foreach ($summary['warehouse_pallets'] as $p) {
            $slips[] = ['station' => 4, 'title' => 'Posição '.$p['location'].' — palete '.$p['tag'], 'sub' => 'Coloque a etiqueta do palete '.$p['tag'].' nesta bandeja', 'items' => $p['items']];
        }
        foreach ($summary['orders_to_ship'] as $o) {
            $slips[] = ['station' => 5, 'title' => 'Pedido nº '.$o['id'].' — pronto para envio', 'sub' => $o['partner'], 'items' => $o['items']];
        }
    @endphp

    <h1>Pacote de Preparação do Treinamento</h1>
    <div class="subtitle">{{ config('app.name') }} — preparado em {{ \Carbon\Carbon::parse($summary['prepared_at'])->format('F j, Y g:i A') }}
        — {{ $summary['products']['units'] }} itens escaneados, {{ $summary['products']['distinct'] }} produtos diferentes</div>

    @foreach ($summary['warnings'] ?? [] as $warning)
        <p class="warning">{{ $warning }}</p>
    @endforeach

    <div class="section">
        <h2>Como funciona</h2>
        <p>Somente a primeira equipe em cada estação precisa de mercadorias preparadas: as equipes avançam da estação N para N+1; assim, após a primeira parada,
            cada equipe trabalha com o que ela mesma movimentou na estação anterior. No recebimento, use suas próprias mercadorias (não escaneadas): deixe
            caixas disponíveis para receber, e as equipes farão a triagem do que trouxerem. As estações 3–5 contêm as mercadorias escaneadas, organizadas
            conforme a lista abaixo. Quando uma equipe marcar uma carga como entregue (Estação 6, Rodada 2), leve a caixa de volta ao Recebimento como uma nova entrega.</p>
        <table>
            <thead><tr><th>Estação</th><th>Preparação</th><th class="num">Itens</th></tr></thead>
            <tbody>
                <tr><td>1 {{ $stations[1] }}</td><td>Caixas com suas mercadorias para recebimento ({{ count($summary['offers']) }} ofertas aguardando)</td><td class="num">suas</td></tr>
                <tr><td>2 {{ $stations[2] }}</td><td>Nada — as equipes fazem a triagem do que receberam</td><td class="num">0</td></tr>
                <tr><td>3 {{ $stations[3] }}</td><td>Mercadorias triadas na mesa da área de triagem</td><td class="num">{{ collect($summary['sorting_area'])->sum('qty') }}</td></tr>
                <tr><td>4 {{ $stations[4] }}</td><td>{{ count($summary['warehouse_pallets']) }} bandejas lacradas nas posições das mesas, {{ count($summary['orders_to_fill']) }} pedidos para separar</td><td class="num">{{ collect($summary['warehouse_pallets'])->flatMap(fn ($p) => $p['items'])->sum('qty') }}</td></tr>
                <tr><td>5 {{ $stations[5] }}</td><td>{{ count($summary['orders_to_ship']) }} pedidos separados junto à saída</td><td class="num">{{ collect($summary['orders_to_ship'])->flatMap(fn ($o) => $o['items'])->sum('qty') }}</td></tr>
                <tr><td>6 {{ $stations[6] }}</td><td>Nada — cada equipe entrega a carga que enviou</td><td class="num">0</td></tr>
            </tbody>
        </table>
        <p class="note">Cole as etiquetas de posição das mesas (Configuração &gt; Armazém de Treinamento &gt; Etiquetas de Posições das Mesas) nas mesas: {{ implode(', ', $summary['locations']) }}.
            Imprima também as etiquetas de palete para as bandejas da Estação 4. As listas de conteúdo (Estações 3–5) e as placas das estações ficam no final deste pacote.</p>
    </div>

    <div class="section">
        <h2>Estação 1 — {{ $stations[1] }}: ofertas aguardando recebimento</h2>
        <p class="note">Disponha caixas com suas próprias mercadorias para recebimento; a equipe de recebimento associará cada entrega a uma destas ofertas registradas por telefone.</p>
        <table>
            <thead><tr><th>Oferta nº</th><th>Doador</th><th>Itens previstos</th></tr></thead>
            <tbody>
                @foreach ($summary['offers'] as $o)
                    <tr><td>{{ $o['id'] }}</td><td>{{ $o['donor'] }}</td><td>{{ $o['description'] }}</td></tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div class="section">
        <h2>Estação 3 — {{ $stations[3] }}: mesa da área de triagem</h2>
        <p class="note">Itens já triados, ainda sem palete — a primeira equipe monta um palete com eles e o coloca em uma posição da mesa.</p>
        <table>
            <tbody>@foreach ($itemRows($summary['sorting_area']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
        </table>
    </div>

    <div class="section">
        <h2>Estação 4 — {{ $stations[4] }}: bandejas lacradas nas mesas</h2>
        @foreach ($summary['warehouse_pallets'] as $p)
            <h3>Posição {{ $p['location'] }} — palete {{ $p['tag'] }}</h3>
            <table>
                <tbody>@foreach ($itemRows($p['items']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
            </table>
        @endforeach
        <h3>Pedidos aguardando separação (Pronto para separação)</h3>
        <table>
            <thead><tr><th>Pedido nº</th><th>Entidade parceira</th><th>Itens</th></tr></thead>
            <tbody>
                @foreach ($summary['orders_to_fill'] as $o)
                    <tr><td>{{ $o['id'] }}</td><td>{{ $o['partner'] }}</td>
                        <td>@foreach ($o['lines'] as $l){{ $l['qty'] }} × {{ $l['number'] }} {{ $l['name'] }}@if (! $loop->last), @endif @endforeach</td></tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <div class="section">
        <h2>Estação 5 — {{ $stations[5] }}: pedidos separados junto à saída</h2>
        @foreach ($summary['orders_to_ship'] as $o)
            <h3>Pedido nº {{ $o['id'] }} — {{ $o['partner'] }}</h3>
            <table>
                <tbody>@foreach ($itemRows($o['items']) as $r)<tr><td>{{ $r['what'] }}</td><td>{{ $r['acs'] }}</td><td class="num">{{ $r['qty'] }}</td></tr>@endforeach</tbody>
            </table>
        @endforeach
    </div>

    <div class="section">
        <h2>Estação 6 — {{ $stations[6] }}: motoristas das equipes (acesso ao Portal do Motorista)</h2>
        <p class="note">Na Rodada 2, cada equipe entrega ao próprio motorista a carga que enviou na Estação 5.</p>
        <table>
            <thead><tr><th>Equipe</th><th>Motorista</th><th>Telefone</th><th>PIN</th></tr></thead>
            <tbody>
                @foreach ($summary['team_drivers'] as $d)
                    <tr><td>{{ $d['team'] }}</td><td>{{ $d['name'] }}</td><td>{{ $d['phone'] }}</td><td>{{ $d['pin'] }}</td></tr>
                @endforeach
            </tbody>
        </table>
        <p class="note">O cadastro de pedidos (Rodada 1) usa estas entidades parceiras de treinamento: {{ implode(', ', $summary['partners']) }}.</p>
    </div>

    {{-- Contents slips: cut apart; one goes in each box / on each tray. --}}
    <div class="new-page">
        <h2>Listas de conteúdo — recorte e coloque uma em cada posição e carga</h2>
        @foreach ($slips as $slip)
            <div class="slip">
                <div class="slip-station">Estação {{ $slip['station'] }} — {{ $stations[$slip['station']] }}</div>
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
            <div class="sign-number">Estação {{ $number }}</div>
            <div class="sign-name">{{ $name }}</div>
        </div>
    @endforeach
</body>
</html>
