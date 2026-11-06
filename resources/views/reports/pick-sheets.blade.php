<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Pick Sheets</title>
    <style>
        @page {
            size: letter;
            margin: 0.75in 0.5in 0.5in 0.5in;
            @top-left {
                content: "Lista de Separação — gerada em {{ $generatedAt->format('F j, Y g:ia') }}";
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
            font-size: 20px;
            margin: 0 0 2px 0;
        }
        .subtitle {
            color: #666;
            font-size: 12px;
            margin-bottom: 16px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            font-size: 11px;
            margin-top: 12px;
        }
        thead {
            display: table-header-group;
        }
        tr {
            break-inside: avoid;
            page-break-inside: avoid;
        }
        th, td {
            text-align: left;
            padding: 5px 6px;
            border-bottom: 1px solid #eee;
        }
        th {
            color: #666;
            font-weight: normal;
            border-bottom: 2px solid #ccc;
        }
        td.where {
            font-size: 10px;
        }
        th.qty, td.qty {
            width: 90px;
            text-align: center;
        }
        th.picked, td.picked {
            width: 60px;
            text-align: center;
        }
        td.picked {
            border: 1px solid #bbb;
            border-radius: 3px;
            height: 20px;
        }
        .signoff {
            margin-top: 30px;
            font-size: 11px;
        }
        .signoff .line {
            display: inline-block;
            border-bottom: 1px solid #999;
            width: 220px;
            height: 18px;
            margin-right: 8px;
        }
        .order-page {
            page-break-after: always;
        }
        .order-page:last-child {
            page-break-after: auto;
        }
    </style>
</head>
<body>
@foreach($orders as $order)
    <div class="order-page">
        <h1>Lista de Separação — Pedido nº {{ $order->id }}</h1>
        <div class="subtitle">
            {{ $order->person?->full_name ?? 'Não informado' }}
            @if($order->order_date) &mdash; {{ \Illuminate\Support\Carbon::parse($order->order_date)->format('F j, Y') }} @endif
        </div>

        <table>
            <thead>
                <tr>
                    <th>Item nº</th>
                    <th>Nome</th>
                    <th>Unidade</th>
                    <th>Local</th>
                    <th class="qty">Qtd. a separar</th>
                    <th class="picked">Separado</th>
                </tr>
            </thead>
            <tbody>
                {{-- Lines approved at 0 have nothing to pick, so they're left off the sheet. --}}
                @php
                    // Walking order along the pick path: sorting area first, lines with no known location last.
                    $pickLines = $order->orderLines->where('qty_to_pick', '>', 0)
                        ->sortBy(fn ($l) => [($plans[$l->id]['first_sequence'] ?? null) === null ? 1 : 0, $plans[$l->id]['first_sequence'] ?? 0, $l->id])->values();
                @endphp
                @forelse($pickLines as $line)
                    <tr>
                        <td>{{ $line->itemtype?->display_number ?? '' }}</td>
                        <td>{{ $line->itemtype?->name }}</td>
                        <td>{{ $line->itemtype?->unit?->abbreviation ?? $line->itemtype?->unit?->name }}</td>
                        <td class="where">
                            @foreach(($plans[$line->id]['steps'] ?? []) as $step)
                                <div>
                                    @if($step['kind'] === 'pool')
                                        Área de triagem &times;{{ $step['qty'] }}
                                    @else
                                        <strong>{{ $step['location'] ?? 'sem localização' }}</strong> {{ $step['tag'] }} &times;{{ $step['qty'] }}@if(!empty($step['expires_on'])) (validade {{ $step['expires_on'] }})@endif @if(!empty($step['whole'])) <em>(retirar o palete inteiro)</em>@elseif($step['needs_open']) <em>(abrir o palete primeiro)</em>@endif
                                    @endif
                                </div>
                            @endforeach
                            @if(($plans[$line->id]['pallet_short'] ?? 0) > 0)
                                @php($others = collect($plans[$line->id]['others'] ?? [])->map(fn ($o) => 'área de triagem × '.$o['qty'])->implode(', '))
                                <div><em>{{ $plans[$line->id]['pallet_short'] }} fora de paletes — procure também{{ $others !== '' ? ': '.$others : '' }}</em></div>
                            @endif
                            @if(($plans[$line->id]['short'] ?? 0) > 0)
                                <div><em>{{ $plans[$line->id]['short'] }} não encontrado no estoque</em></div>
                            @endif
                        </td>
                        <td class="qty">{{ $line->qty_to_pick }}</td>
                        <td class="picked"></td>
                    </tr>
                @empty
                    <tr><td colspan="6">Não há itens para separar neste pedido.</td></tr>
                @endforelse
            </tbody>
        </table>

        <div class="signoff">
            Separado por: <span class="line"></span> Data: <span class="line" style="width:120px;"></span>
        </div>
    </div>
@endforeach
</body>
</html>
