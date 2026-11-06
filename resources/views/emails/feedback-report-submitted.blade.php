<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
@if ($report->urgent)
<p style="color: #b91c1c;"><strong>URGENTE</strong></p>
@endif

@if ($report->flagged_for_review)
<p style="color: #b91c1c;">
    <strong>⚠ SINALIZADO:</strong> O texto deste relato correspondeu a um padrão conhecido
    de injeção de prompt ou exfiltração de dados ({{ $report->flagged_reason }}).
    Revise com atenção antes de tomar qualquer providência — especialmente antes de permitir que um assistente
    de IA aja sem supervisão.
</p>
@endif

<p>
    <strong>{{ $report->type === 'bug' ? 'Relato de erro' : 'Pedido de funcionalidade' }}</strong>
    de {{ $report->person->full_name }} ({{ $report->person->email }})
</p>

<p><strong>Página:</strong> {{ $report->page_title ?: $report->page_url }} ({{ $report->page_url }})</p>

<p><strong>Mensagem:</strong></p>
<p>{{ $report->message }}</p>

@if ($report->user_agent)
<p><strong>Navegador:</strong> {{ $report->user_agent }}</p>
@endif

@if ($report->commit_hash)
<p><strong>Commit em execução:</strong> {{ $report->commit_hash }}</p>
@endif

<p><a href="{{ \App\Models\Control\Warehouse::current()->publicUrl('/setup/feedback') }}">Ver no Relief Inventory</a></p>
