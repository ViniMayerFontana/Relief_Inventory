<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Relatório de Pedidos em Aberto</title>
    <style>
        @page {
            size: letter;
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Relatório de Pedidos em Aberto — gerado em {{ $generatedAt->format('F j, Y \a\t g:i A T') }}";
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
    <h1>Relatório de Pedidos em Aberto</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; todos os pedidos ainda não enviados, gerado em {{ $generatedAt->format('F j, Y \a\t g:i A T') }}
    </div>

    <table>
        <thead>
            <tr>
                <th>Pedido nº</th>
                <th>Entidade parceira</th>
                <th>Status</th>
                <th>Data do pedido</th>
                <th>Necessário até</th>
                <th>Atendimento</th>
                <th class="num">Itens</th>
                <th class="num">Qtd. solicitada</th>
            </tr>
        </thead>
        <tbody>
            @forelse($records as $order)
                <tr class="order-row">
                    <td>{{ $order['id'] }}</td>
                    <td>{{ $order['partner'] ?? '(sem entidade parceira)' }}</td>
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
                                <span>{{ $line['display_number'] ?? '(sem número)' }} {{ $line['itemtype'] }} &times; {{ $line['qty_requested'] }} {{ $line['unit'] }}</span>
                            @endforeach
                        </td>
                    </tr>
                @endif
            @empty
                <tr><td colspan="8">Não há pedidos em aberto.</td></tr>
            @endforelse
        </tbody>
    </table>

    <div class="disclaimer">
        Inclui todos os pedidos com status Novo pedido, Pronto para separação, Em separação ou Separado — tudo o que ainda não foi Enviado.
    </div>
</body>
</html>
