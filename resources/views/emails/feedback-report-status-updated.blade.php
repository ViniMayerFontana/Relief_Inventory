<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
@php
    $labels = ['seen' => 'Recebido', 'in_development' => 'Em desenvolvimento', 'resolved' => 'Resolvido'];
    $report = $log->feedbackReport;
@endphp

<p>Olá, {{ $report->reporterFullName() }}.</p>

@if ($isTransition)
<p>
    Seu {{ $report->type === 'bug' ? 'relato de erro' : 'pedido de funcionalidade' }}
    "{{ \Illuminate\Support\Str::limit($report->message, 80) }}" agora está
    <strong>{{ $labels[$log->status] ?? $log->status }}</strong>.
</p>
@else
<p>
    Um novo comentário foi adicionado ao seu {{ $report->type === 'bug' ? 'relato de erro' : 'pedido de funcionalidade' }}
    "{{ \Illuminate\Support\Str::limit($report->message, 80) }}"
    (atualmente <strong>{{ $labels[$log->status] ?? $log->status }}</strong>):
</p>
@endif

@if ($log->comment)
<p><strong>Nota da equipe de desenvolvimento:</strong></p>
<p>{{ $log->comment }}</p>
@endif

<p>Agradecemos por ajudar a melhorar o Relief Inventory.</p>
