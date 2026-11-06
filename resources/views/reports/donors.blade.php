@php
    $f = $report['filters'];
    $t = $report['totals'];
    $c = $report['thresholds'];
    $pct = fn ($v) => $v === null ? '—' : $v.'%';
    $range = match (true) {
        ! empty($f->from) && ! empty($f->to) => 'doações de '.$f->from.' a '.$f->to,
        ! empty($f->from) => 'doações a partir de '.$f->from,
        ! empty($f->to) => 'doações até '.$f->to,
        default => 'todas as doações',
    };
@endphp
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Relatório de Doadores</title>
    <style>
        @page {
            size: letter;
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Relatório de Doadores — gerado em {{ $generatedAt->format('F j, Y \a\t g:i A T') }}";
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
        tr.donor td { font-weight: bold; border-top: 1px solid #ccc; }
        tr.donation td { color: #555; font-size: 10px; }
        tr.donation td.indent { padding-left: 22px; }
        .muted { color: #888; font-weight: normal; }
        .disclaimer { font-size: 10.5px; color: #888; font-style: italic; border-top: 1px solid #ddd; padding-top: 6px; margin-top: 22px; }
    </style>
</head>
<body>
    <h1>Relatório de Doadores</h1>
    <div class="subtitle">
        {{ config('app.name') }} &mdash; o que cada doador enviou e quanto pôde ser aproveitado, {{ $range }}, gerado em
        {{ $generatedAt->format('F j, Y \a\t g:i A T') }}
    </div>

    <div class="summary">
        <strong>{{ $t['donors'] }}</strong> {{ $t['donors'] === 1 ? 'doador' : 'doadores' }},
        <strong>{{ $t['donations'] }}</strong> {{ $t['donations'] === 1 ? 'doação triada' : 'doações triadas' }},
        <strong>{{ number_format($t['units']) }}</strong> unidades triadas, perda geral de <strong>{{ $pct($t['loss_percent']) }}</strong>.
        {{ $t['watch'] }} em observação, {{ $t['decline'] }} com recomendação de recusa; {{ $t['needs_review'] }} com recomendação diferente da classificação atual.
    </div>

    @if($report['donors']->isEmpty())
        <p>Nenhuma doação{{ $range === 'todas as doações' ? '' : ' neste período' }}.</p>
    @else
        <h2>Doadores</h2>
        <table>
            <thead>
                <tr>
                    <th>Doador / Doação</th><th>Classificação atual</th><th>Recomendação</th><th class="num">Doações</th>
                    <th class="num">Unidades</th><th class="num">Aproveitáveis</th><th class="num">Vencidos</th>
                    <th class="num">Descartados</th><th class="num">Redirecionados</th><th class="num">Perda %</th>
                </tr>
            </thead>
            <tbody>
                @foreach($report['donors'] as $d)
                    <tr class="donor">
                        <td>{{ $d['name'] }}</td>
                        <td>{{ $d['is_system'] ? '' : ucfirst($d['standing']) }}</td>
                        <td>{!! $d['is_system'] ? '' : ($d['suggested'] ? ucfirst($d['suggested']) : '<span class="muted">dados insuficientes</span>') !!}</td>
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
                            <td class="indent">#{{ $n['id'] }} &middot; {{ $n['date'] }} &middot; {{ $n['status'] }}</td>
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
        Perda % = (vencidos + descartados) &divide; total triado; itens redirecionados não são contabilizados como perda do doador.
        A recomendação de classificação exige pelo menos {{ $c['min_donations'] }} doações triadas e {{ $c['min_units'] }} unidades:
        observação a partir de {{ $c['watch_loss_percent'] }}% de perda; recusa a partir de {{ $c['decline_loss_percent'] }}% em
        {{ $c['decline_min_donations'] }} ou mais doações; preferência com perda de até {{ $c['preferred_loss_percent'] }}% em
        {{ $c['preferred_min_donations'] }} ou mais doações e {{ $c['preferred_min_units'] }} ou mais unidades.
        A recomendação não é uma decisão: a classificação exibida foi definida pela equipe.
        As quantidades usam a unidade própria de cada item.
    </div>
</body>
</html>
