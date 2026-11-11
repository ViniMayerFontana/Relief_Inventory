{{-- Training report cards (TrainingReportController::pdfBuilder): one row per trainee, a tick per station. --}}
@php
    $f = $report['filters'];
    $range = $f['from'] === $f['to'] ? \Carbon\Carbon::parse($f['from'])->translatedFormat(app()->getLocale() === 'pt_BR' ? 'j \d\e F \d\e Y' : 'F j, Y')
        : \Carbon\Carbon::parse($f['from'])->format('M j, Y').' – '.\Carbon\Carbon::parse($f['to'])->format('M j, Y');
@endphp
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>{{ __("Reports.Training.ReportCards.text.training_report_cards") }}</title>
    <style>
        @page { size: {{ \App\Support\ReportPaper::size() }} landscape; margin: 0.5in; }
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
    <h1>{{ __("Reports.Training.ReportCards.text.training_report_cards") }}</h1>
    <div class="subtitle">
        {{ config('app.name') }} — {{ $range }}{{ ! empty($f['team']) ? ', Team '.$f['team'] : '' }}
        — {{ $report['totals']['complete'] }} of {{ $report['totals']['trainees'] }} trainees completed all six stations
    </div>

    @if (count($report['trainees']) === 0)
        <p>{{ __("Reports.Training.ReportCards.text.no_trainee_activity_in") }}</p>
    @else
        <table>
            <thead>
                <tr>
                    <th>{{ __("Commons.text.trainee") }}</th>
                    <th>{{ __("Commons.text.team") }}</th>
                    @foreach ($report['stations'] as $n => $name)
                        <th>{{ $n }}. {{ $name }}</th>
                    @endforeach
                    <th>{{ __("Commons.text.result") }}</th>
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
                        <td class="{{ $t['complete'] ? 'complete' : '' }}">{{ $t['complete'] ? 'Complete' : $t['done'].' of 6' }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
        <p style="color:#666; margin-top: 8px;">{{ __("Reports.Training.ReportCards.text.each_number_is_how") }}</p>
    @endif
</body>
</html>
