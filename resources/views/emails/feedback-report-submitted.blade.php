<!-- This file is part of the Relief Inventory Project (https://reliefinventory.app)
     Licensed under the GNU GPL v. 3. See LICENSE.md for details -->
@if ($report->urgent)
<p style="color: #b91c1c;"><strong>{{ __('mail.urgent') }}</strong></p>
@endif

@if ($report->flagged_for_review)
<p style="color: #b91c1c;">
    <strong>{{ __('mail.flagged_intro') }}</strong>
    {{ __('mail.flagged_body', ['reason' => $report->flagged_reason]) }}
</p>
@endif

<p>
    <strong>{{ $report->type === 'bug' ? __('mail.feedback_label_bug') : __('mail.feedback_label_feature') }}</strong>
    {{ __('mail.from') }} {{ $report->person->full_name }} ({{ $report->person->email }})
</p>

<p><strong>{{ __('mail.page_label') }}</strong> {{ $report->page_title ?: $report->page_url }} ({{ $report->page_url }})</p>

<p><strong>{{ __('mail.message_label') }}</strong></p>
<p>{{ $report->message }}</p>

@if ($report->user_agent)
<p><strong>{{ __('mail.browser_label') }}</strong> {{ $report->user_agent }}</p>
@endif

@if ($report->commit_hash)
<p><strong>{{ __('mail.running_commit_label') }}</strong> {{ $report->commit_hash }}</p>
@endif

<p><a href="{{ \App\Models\Control\Warehouse::current()->publicUrl('/setup/feedback') }}">{{ __('mail.view_in_ri') }}</a></p>
