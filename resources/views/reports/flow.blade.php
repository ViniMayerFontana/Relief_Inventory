@php
    $f = $report['filters'];
    $t = $report['totals'];
    $signed = fn ($n) => ($n > 0 ? '+' : '').number_format($n);
@endphp
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Relatório de Movimentação de Estoque</title>
    <style>
        @page {
            size: letter;
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Relatório de Movimentação de Estoque — gerado em {{ $generatedAt->format('F j, Y \a\t g:i A T') }}";
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
        .disclaimer { font-size: 10.5px; color: #888; font-style: italic; border-top: 1px solid #ddd; padding-top: 6px; margin-top: 22px; }
    </style>
</head>
<body>
    <h1>Relatório de Movimentação de Estoque</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; de {{ $f->from }} a {{ $f->to }}, por {{ $f->bucket }}, gerado em
        {{ $generatedAt->format('F j, Y \a\t g:i A T') }}
    </div>

    <div class="summary">
        Saldo inicial <strong>{{ number_format($t['opening']) }}</strong>
        + recebidos <strong>{{ number_format($t['received']) }}</strong>
        &minus; separados <strong>{{ number_format($t['picked']) }}</strong>
        {{ $t['adjustments'] < 0 ? '&minus;' : '+' }} ajustes <strong>{{ number_format(abs($t['adjustments'])) }}</strong>
        = saldo final <strong>{{ number_format($t['closing']) }}</strong>.
        Fora do estoque: {{ number_format($t['outdated']) }} vencidos, {{ number_format($t['trashed']) }} descartados,
        {{ number_format($t['diverted']) }} redirecionados.
    </div>

    <h2>Por {{ $f->bucket }}</h2>
    <table>
        <thead><tr>
            <th>Início do período</th><th class="num">Recebidos</th><th class="num">Separados</th><th class="num">Ajustes</th>
            <th class="num">Saldo final</th><th class="num">Vencidos</th><th class="num">Descartados</th><th class="num">Redirecionados</th>
        </tr></thead>
        <tbody>
            @foreach($report['buckets'] as $b)
                <tr>
                    <td>{{ $b['start'] }}</td>
                    <td class="num">{{ number_format($b['received']) }}</td>
                    <td class="num">{{ number_format($b['picked']) }}</td>
                    <td class="num">{{ $signed($b['adjustments']) }}</td>
                    <td class="num">{{ number_format($b['on_hand']) }}</td>
                    <td class="num">{{ number_format($b['outdated']) }}</td>
                    <td class="num">{{ number_format($b['trashed']) }}</td>
                    <td class="num">{{ number_format($b['diverted']) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    @if(count($report['adjustment_reasons']))
        <h2>Ajustes por motivo</h2>
        <table>
            <thead><tr><th>Motivo</th><th class="num">Adicionados</th><th class="num">Removidos</th></tr></thead>
            <tbody>
                @foreach($report['adjustment_reasons'] as $r)
                    <tr><td>{{ $r['label'] }}</td><td class="num">{{ number_format($r['added']) }}</td><td class="num">{{ number_format($r['removed']) }}</td></tr>
                @endforeach
            </tbody>
        </table>
    @endif

    <h2>Por item</h2>
    <table>
        <thead><tr>
            <th>Item nº</th><th>Item</th><th>Unidade</th><th class="num">Saldo inicial</th><th class="num">Recebidos</th>
            <th class="num">Separados</th><th class="num">Ajustes</th><th class="num">Saldo final</th>
            <th class="num">Vencidos</th><th class="num">Descartados</th><th class="num">Redirecionados</th>
        </tr></thead>
        <tbody>
            @foreach($report['items'] as $i)
                <tr>
                    <td>{{ $i['display_number'] ?? '—' }}</td>
                    <td>{{ $i['name'] }}</td>
                    <td>{{ $i['unit'] }}</td>
                    <td class="num">{{ number_format($i['opening']) }}</td>
                    <td class="num">{{ number_format($i['received']) }}</td>
                    <td class="num">{{ number_format($i['picked']) }}</td>
                    <td class="num">{{ $signed($i['adjustments']) }}</td>
                    <td class="num">{{ number_format($i['closing']) }}</td>
                    <td class="num">{{ number_format($i['outdated']) }}</td>
                    <td class="num">{{ number_format($i['trashed']) }}</td>
                    <td class="num">{{ number_format($i['diverted']) }}</td>
                </tr>
            @endforeach
        </tbody>
    </table>

    <div class="disclaimer">
        Recebidos = itens aproveitáveis triados; separados = itens incluídos nos pedidos; ajustes = correções
        manuais de estoque (saldo líquido). Itens vencidos, descartados e redirecionados não fazem parte do estoque
        nem alteram o saldo disponível. Mover um palete altera a localização, não a quantidade, por isso não aparece
        aqui. As quantidades usam a unidade própria de cada item; portanto, os totais de itens diferentes somam unidades distintas.
    </div>
</body>
</html>
