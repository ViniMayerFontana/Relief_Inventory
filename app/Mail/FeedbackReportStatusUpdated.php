<?php

// This file is part of the Relief Inventory Project (https://reliefinventory.app)
// Licensed under the GNU GPL v. 3. See LICENSE.md for details

namespace App\Mail;

use App\Models\FeedbackReportStatusLog;
use Illuminate\Bus\Queueable;
use Illuminate\Mail\Mailable;
use Illuminate\Queue\SerializesModels;

class FeedbackReportStatusUpdated extends Mailable
{
    use Queueable, SerializesModels;

    /**
     * $isTransition is false when this log entry is a note left while the
     * status stayed the same (FeedbackReports.vue's "Add note" action) —
     * the subject/body read differently ("a note was added") than an
     * actual status change ("is now Acknowledged").
     */
    public function __construct(public FeedbackReportStatusLog $log, public bool $isTransition = true) {}

    public function build()
    {
        $labels = [
            'new' => trans('mail.feedback_status_new'),
            'seen' => trans('mail.feedback_status_seen'),
            'in_development' => trans('mail.feedback_status_in_development'),
            'resolved' => trans('mail.feedback_status_resolved'),
        ];

        $subject = $this->isTransition
            ? trans('mail.feedback_status_transition_subject', ['status' => $labels[$this->log->status] ?? $this->log->status])
            : trans('mail.feedback_status_comment_subject');

        return $this->subject($subject)
            ->view('emails.feedback-report-status-updated');
    }
}
