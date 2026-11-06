@php
    $range = match (true) {
        ! empty($filters['from']) && ! empty($filters['to']) => 'pedidos de '.$filters['from'].' a '.$filters['to'],
        ! empty($filters['from']) => 'pedidos a partir de '.$filters['from'],
        ! empty($filters['to']) => 'pedidos até '.$filters['to'],
        default => 'todos os pedidos',
    };
    $totals = $report['totals'];
@endphp
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Relatório de Solicitações Não Atendidas</title>
    <style>
        @page {
            size: letter;
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Relatório de Solicitações Não Atendidas — gerado em {{ $generatedAt->format('F j, Y \a\t g:i A T') }}";
                font-family: Arial, sans-serif;
                font-size: 9px;
                color: #888;
            }
            @top-right {
                content: "Página " counter(page) " de " counter(pages);
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
    <h1>Relatório de Solicitações Não Atendidas</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; o que foi solicitado, mas não atendido, {{ $range }}, gerado em
        {{ $generatedAt->format('F j, Y \a\t g:i A T') }}
    </div>

    <div class="summary">
        <strong>{{ $totals['item_types'] }}</strong> tipos de item em falta em
        <strong>{{ $totals['requests'] }}</strong> solicitações:
        <strong>{{ number_format($totals['requested']) }}</strong> solicitadas,
        <strong>{{ number_format($totals['filled']) }}</strong> atendidas,
        <strong class="short">{{ number_format($totals['not_filled']) }}</strong> não atendidas
        ({{ number_format($totals['cut_at_allocation']) }} reduzidas na alocação,
        {{ number_format($totals['short_at_picking']) }} em falta na separação).
    </div>

    @if($report['items']->isEmpty())
        <p>Nenhuma solicitação não atendida{{ $range === 'todos os pedidos' ? '' : ' neste período' }}.</p>
    @else
        <div class="columns">
            @foreach(['county' => 'Município', 'zip' => 'CEP'] as $field => $label)
                <div>
                    <h2>Não atendidos por {{ $label }}</h2>
                    <table>
                        <thead><tr>
                            <th>{{ $label }}</th><th class="num">Solicitações</th><th class="num">Tipos de item</th><th class="num">Não atendidos</th>
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

        <h2>Itens não atendidos</h2>
        <table>
            <thead>
                <tr>
                    <th>Item nº</th>
                    <th>Item / Município &middot; CEP</th>
                    <th>Unidade</th>
                    <th class="num">Solicitações</th>
                    <th class="num">Solicitado</th>
                    <th class="num">Atendido</th>
                    <th class="num">Não atendido</th>
                    <th class="num">Reduzido na alocação</th>
                    <th class="num">Em falta na separação</th>
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
        Contabiliza apenas solicitações cuja separação foi concluída (de Separado a Concluído, além de Fechado — Não atendido);
        solicitações ainda em cadastro ou separação não são incluídas. Não atendido = solicitado &minus; atendido.
        Reduzido na alocação = quantidade aprovada menor que a solicitada durante a revisão da alocação; em falta na
        separação = quantidade aprovada, mas não separada. Município e CEP são os da entidade parceira solicitante.
        As quantidades usam a unidade própria de cada item, portanto os totais de itens diferentes somam unidades distintas.
    </div>
</body>
</html>
