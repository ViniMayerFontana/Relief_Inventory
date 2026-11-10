<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
@php
    $labels = [
        'seen' => __('mail.feedback_status_seen'),
        'in_development' => __('mail.feedback_status_in_development'),
        'resolved' => __('mail.feedback_status_resolved'),
    ];
    $report = $log->feedbackReport;
    $type = $report->type === 'bug' ? __('mail.type_bug') : __('mail.type_feature');
@endphp

<p>{{ __('mail.account_greeting', ['name' => $report->reporterFullName()]) }}</p>

@if ($isTransition)
<p>
    {{ __('mail.status_transition_body', ['type' => $type, 'message' => \Illuminate\Support\Str::limit($report->message, 80)]) }}
    <strong>{{ $labels[$log->status] ?? $log->status }}</strong>.
</p>
@else
<p>
    {{ __('mail.status_comment_body', ['type' => $type]) }}
    "{{ \Illuminate\Support\Str::limit($report->message, 80) }}"
    ({{ __('mail.currently') }} <strong>{{ $labels[$log->status] ?? $log->status }}</strong>):
</p>
@endif

@if ($log->comment)
<p><strong>{{ __('mail.note_from_developer') }}</strong></p>
<p>{{ $log->comment }}</p>
@endif

<p>{{ __('mail.thanks_helping') }}</p>
