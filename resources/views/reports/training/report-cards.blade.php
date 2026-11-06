{{-- Training report cards (TrainingReportController::pdfBuilder): one row per trainee, a tick per station. --}}
@php
    $f = $report['filters'];
    $range = $f['from'] === $f['to'] ? \Carbon\Carbon::parse($f['from'])->format('F j, Y')
        : \Carbon\Carbon::parse($f['from'])->format('M j, Y').' – '.\Carbon\Carbon::parse($f['to'])->format('M j, Y');
@endphp
<!DOCTYPE html>
<html lang="pt-BR">
<head>
    <meta charset="UTF-8">
    <title>Fichas de Avaliação do Treinamento</title>
    <style>
        @page { size: letter landscape; margin: 0.5in; }
        body { font-family: Arial, sans-serif; color: #222; margin: 0; font-size: 11px; }
        h1 { font-size: 20px; margin: 0 0 2px 0; }
        .subtitle { color: #666; font-size: 11px; margin-bottom: 14px; }
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid #bbb; padding: 4px 6px; text-align: left; vertical-align: top; }
        th { background: #eef2ff; }
        td.station { text-align: center; }
        .yes { color: #166534; font-weight: bold; }
        .no { color: #999; }
        .complete { font-weight: bold; color: #166534; }
    </style>
</head>
<body>
    <h1>Fichas de Avaliação do Treinamento</h1>
    <div class="subtitle">
        {{ config('app.name') }} — {{ $range }}{{ ! empty($f['team']) ? ', Equipe '.$f['team'] : '' }}
        — {{ $report['totals']['complete'] }} de {{ $report['totals']['trainees'] }} participantes concluíram as seis estações
    </div>

    @if (count($report['trainees']) === 0)
        <p>Nenhuma atividade de participantes neste período.</p>
    @else
        <table>
            <thead>
                <tr>
                    <th>Participante</th>
                    <th>Equipe</th>
                    @foreach ($report['stations'] as $n => $name)
                        <th>{{ $n }}. {{ $name }}</th>
                    @endforeach
                    <th>Resultado</th>
                </tr>
            </thead>
            <tbody>
                @foreach ($report['trainees'] as $t)
                    <tr>
                        <td>{{ $t['name'] }}</td>
                        <td>{{ $t['team'] }}</td>
                        @foreach ($t['stations'] as $s)
                            <td class="station">
                                @if ($s['done'])
                                    <span class="yes">&#10003;</span> {{ $s['count'] }}
                                @else
                                    <span class="no">—</span>
                                @endif
                            </td>
                        @endforeach
                        <td class="{{ $t['complete'] ? 'complete' : '' }}">{{ $t['complete'] ? 'Concluído' : $t['done'].' de 6' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        <p style="color:#666; margin-top: 8px;">Cada número indica quantas ações o participante registrou naquela estação.</p>
    @endif
</body>
</html>
