{{-- Training Mode team activity sheets (TrainingAdminController::teamSheetsBuilder): one per team, in that team's
     rotation order, Round 1 (segment 1) and Round 2 (segment 2) for each station. Content: App\Support\TrainingGuide.
     $sheets = [TrainingGuide::sheetFor(n), ...]; $drivers = team => [phone, pin] from the last Prepare Training. --}}
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Folhas das Equipes de Treinamento</title>
    <style>
        @page { size: letter; margin: 0.5in 0.55in; }
        body { font-family: Arial, sans-serif; color: #222; margin: 0; font-size: 11.5px; line-height: 1.4; }
        .sheet { page-break-after: always; }
        .sheet:last-child { page-break-after: auto; }
        h1 { font-size: 22px; margin: 0; }
        .subtitle { color: #666; font-size: 11px; margin: 2px 0 10px 0; }
        .box { border: 1px solid #bbb; border-radius: 4px; padding: 6px 10px; margin-bottom: 10px; background: #f8fafc; }
        table.rotation { border-collapse: collapse; width: 100%; margin-bottom: 10px; }
        table.rotation th, table.rotation td { border: 1px solid #bbb; padding: 3px 6px; text-align: left; }
        table.rotation th { background: #eef2ff; }
        .station { border-top: 2px solid #1e3a8a; padding-top: 4px; margin-top: 8px; page-break-inside: avoid; }
        .station h2 { font-size: 13px; color: #1e3a8a; margin: 0 0 2px 0; }
        .round { margin: 2px 0 4px 0; }
        .round strong { display: block; }
        ol { margin: 2px 0 0 0; padding-left: 18px; }
        li { margin-bottom: 1px; }
        .check { float: right; font-size: 11px; color: #444; }
    </style>
</head>
<body>
@foreach ($sheets as $sheet)
    <div class="sheet">
        <h1>Equipe {{ $sheet['team'] }} — Folha de atividades</h1>
        <div class="subtitle">{{ config('app.name') }} · treinamento prático · dois segmentos de {{ \App\Support\TrainingGuide::SEGMENT_MINUTES }} minutos · cerca de 8 minutos por estação</div>

        <div class="box">
            <strong>Como entrar:</strong> no tablet da estação, toque no seu nome, escolha a Equipe {{ $sheet['team'] }} e toque em Iniciar.
            Seu nome não está na lista? Toque em Adicionar novo. Ao terminar, toque em "Acesso da equipe" na faixa amarela ou passe o tablet para a próxima equipe.
            <strong>Avance</strong> quando o instrutor avisar: vá para a próxima estação da lista abaixo (da Estação 6, volte à Estação 1).
            <br><strong>Segmento 1</strong> = Rodada 1 em todas as estações. <strong>Segmento 2</strong> = Rodada 2 em todas as estações, na mesma ordem.
            @if (! empty($drivers[$sheet['team']]))
                <br><strong>Motorista da equipe (Estação 6, Portal do Motorista):</strong> telefone {{ $drivers[$sheet['team']]['phone'] }}, PIN {{ $drivers[$sheet['team']]['pin'] }}
            @endif
        </div>

        <table class="rotation">
            <thead><tr><th>Horário</th><th>Minutos</th><th>Estação</th><th>Rodada 1 (segmento 1)</th><th>Rodada 2 (segmento 2)</th></tr></thead>
            <tbody>
                @foreach ($sheet['slots'] as $slot)
                    <tr>
                        <td>{{ $slot['slot'] }}</td>
                        <td>{{ $slot['start'] }}–{{ $slot['end'] }}</td>
                        <td>{{ $slot['station'] }}. {{ $slot['name'] }}</td>
                        <td>{{ $slot['activity']['round1']['title'] }}</td>
                        <td>{{ $slot['activity']['round2']['title'] }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        @foreach ($sheet['slots'] as $slot)
            <div class="station">
                <h2>Horário {{ $slot['slot'] }} · Estação {{ $slot['station'] }}: {{ $slot['name'] }} <span style="font-weight:normal; color:#555;">({{ $slot['activity']['page'] }})</span></h2>
                        @foreach (['round1' => 'Rodada 1', 'round2' => 'Rodada 2'] as $key => $label)
                    <div class="round">
                        <span class="check">&#9744; concluído</span>
                        <strong>{{ $label }}: {{ $slot['activity'][$key]['title'] }}</strong>
                        <ol>
                            @foreach ($slot['activity'][$key]['steps'] as $step)
                                <li>{{ $step }}</li>
                            @endforeach
                        </ol>
                    </div>
                @endforeach
            </div>
        @endforeach
    </div>
@endforeach
</body>
</html>
