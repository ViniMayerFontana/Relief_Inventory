@php
    $f = $report['filters'];
    $t = $report['totals'];
    $rate = fn ($v) => $v === null ? '—' : $v.'%';
    $range = match (true) {
        ! empty($f->from) && ! empty($f->to) => 'pedidos de '.$f->from.' a '.$f->to,
        ! empty($f->from) => 'pedidos a partir de '.$f->from,
        ! empty($f->to) => 'pedidos até '.$f->to,
        default => 'todos os pedidos',
    };
@endphp
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Relatório de Entidades Parceiras</title>
    <style>
        @page {
            size: letter;
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Relatório de Entidades Parceiras — gerado em {{ $generatedAt->format('F j, Y \a\t g:i A T') }}";
                font-family: Arial, sans-serif; font-size: 9px; color: #888;
            }
            @top-right {
                content: "Página " counter(page) " de " counter(pages);
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
    <h1>Relatório de Entidades Parceiras</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; o que cada entidade parceira solicitou e recebeu, {{ $range }}, gerado em
        {{ $generatedAt->format('F j, Y \a\t g:i A T') }}
    </div>

    <div class="summary">
        <strong>{{ $t['partners'] }}</strong> {{ $t['partners'] === 1 ? 'entidade parceira' : 'entidades parceiras' }},
        <strong>{{ $t['requests'] }}</strong> {{ $t['requests'] === 1 ? 'solicitação' : 'solicitações' }}:
        <strong>{{ number_format($t['requested']) }}</strong> solicitadas,
        <strong>{{ number_format($t['filled']) }}</strong> atendidas
        (taxa de atendimento dos pedidos concluídos: {{ $rate($t['fill_rate']) }});
        {{ $t['shipped'] }} enviadas, {{ $t['delivered'] }} entregues.
    </div>

    @if($report['partners']->isEmpty())
        <p>Nenhuma solicitação{{ $range === 'todos os pedidos' && empty($f->county_id) ? '' : ' com esses filtros' }}.</p>
    @else
        <h2>Por município</h2>
        <table>
            <thead><tr><th>Município</th><th class="num">Entidades parceiras</th><th class="num">Solicitações</th><th class="num">Solicitado</th><th class="num">Atendido</th></tr></thead>
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

        <h2>Entidades parceiras</h2>
        <table>
            <thead>
                <tr>
                    <th>Entidade parceira / Solicitação</th><th>Município &middot; CEP</th><th class="num">Solicitações</th>
                    <th class="num">Solicitado</th><th class="num">Atendido</th><th class="num">Taxa de atendimento</th>
                    <th class="num">Enviado</th><th class="num">Entregue</th><th>Última solicitação</th>
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
                            <td class="indent">#{{ $o['id'] }} &middot; {{ $o['status'] }}</td>
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
        Todas as solicitações são contabilizadas, independentemente do status. Taxa de atendimento = quantidade atendida &divide;
        solicitada, considerando os pedidos cuja separação foi concluída. Município e CEP são os da entidade parceira.
        As quantidades usam a unidade própria de cada item, portanto os totais somam unidades distintas.
        Consulte o Relatório de Solicitações Não Atendidas para ver o que faltou e por quê.
    </div>
</body>
</html>
