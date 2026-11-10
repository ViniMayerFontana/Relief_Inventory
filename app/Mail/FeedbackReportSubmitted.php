<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Mail;

use App\Models\FeedbackReport;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class FeedbackReportSubmitted extends Mailable
{
    use Queueable, SerializesModels;

    public function __construct(public FeedbackReport $report) {}

    public function build()
    {
        $label = $this->report->type === 'bug' ? trans('mail.feedback_label_bug') : trans('mail.feedback_label_feature');
        $page = $this->report->page_title ?: $this->report->page_url;
        $urgentPrefix = $this->report->urgent ? trans('mail.feedback_urgent_prefix') : '';
        // See FeedbackContentScanner — a flagged report may be a genuine
        // prompt-injection/exfiltration attempt aimed at whoever (human or
        // AI) reads this next. Surface that in the subject line itself, not
        // just the body, so it's visible before anyone opens the email.
        $flaggedPrefix = $this->report->flagged_for_review ? trans('mail.feedback_flagged_prefix') : '';

        return $this->subject(trans('mail.feedback_submitted_subject', [
            'flagged' => $flaggedPrefix,
            'urgent' => $urgentPrefix,
            'label' => $label,
            'page' => $page,
        ]))
            ->view('emails.feedback-report-submitted');
    }
}
